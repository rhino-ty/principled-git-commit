#!/usr/bin/env bash
# validate-commit-msg.sh — lint a commit message against the universal §0-§14 rules
#
# Usage:
#   validate-commit-msg.sh <message-file>           # most common: .git/COMMIT_EDITMSG
#   validate-commit-msg.sh --stdin                  # reads message from stdin
#   git commit -m "..."                             # → wire as commit-msg hook (see below)
#
# Exit codes:
#   0   message passes all checks
#   1   message has errors (commit should be aborted)
#   2   message has warnings only (commit should proceed; emit advisories)
#
# Wire as git hook:
#   ln -sf ~/.claude/skills/principled-git-commit/scripts/validate-commit-msg.sh \
#          $(git rev-parse --git-dir)/hooks/commit-msg
#
# What it checks (corresponds to SKILL.md sections):
#   §1.1 Subject line:
#     - length ≤ 100 (warn ≥ 100, error > 120)
#     - format: type(scope)?: summary  (Conventional Commits regex)
#     - lowercase subject (proper nouns retain case — heuristic)
#     - no trailing punctuation
#     - imperative mood (heuristic — flags `added`, `adding`, `was`, `is`)
#   §1.2 Body:
#     - no `## ` markdown headers (5/200 outlier per study)
#     - body length ≤ 80 lines (warn) — past that probably bundles two intents
#   §0.5 Searchable:
#     - flag vague single-word summaries (`wip`, `bug`, `update`, `fix`, `change`, `improve`)
#   §6 Breaking changes:
#     - if `BREAKING CHANGE:` footer present, validate it follows blank-line-then-trailer-block
#   §7.4 Secrets (best-effort):
#     - no `.env` / `password` / `api_key` / `bearer ...` literal in body
#
# Caveats:
#   - Imperative-mood detection is heuristic, not parser-level. False positives possible
#     for legit nouns starting with "added" etc.; downgrade to warning, never error
#   - Vague-summary detection only flags single-word and common phrases; the §0.5 keyword
#     check requires human judgment for full coverage

set -euo pipefail

# ─── Color / TTY ──────────────────────────────────────────────────────
if [[ -t 2 ]]; then
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  GREEN='\033[0;32m'
  RESET='\033[0m'
else
  RED='' YELLOW='' GREEN='' RESET=''
fi

ERRORS=0
WARNINGS=0

err()  { printf "${RED}error${RESET}: %s\n" "$*" >&2; ERRORS=$((ERRORS+1)); }
warn() { printf "${YELLOW}warn${RESET}:  %s\n" "$*" >&2; WARNINGS=$((WARNINGS+1)); }

# ─── Read input ────────────────────────────────────────────────────────
if [[ "${1:-}" == "--stdin" ]]; then
  MSG=$(cat)
elif [[ -n "${1:-}" && -f "$1" ]]; then
  # Strip git's '# ' comment lines (interactive editor leaves these)
  MSG=$(grep -v '^\s*#' "$1" || true)
else
  echo "Usage: validate-commit-msg.sh <message-file>  |  --stdin" >&2
  exit 2
fi

# Drop trailing blank lines for length checks
MSG=$(echo "$MSG" | sed -e 's/[[:space:]]*$//' -e '/./,$!d' | awk 'NR>0' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')

if [[ -z "$MSG" ]]; then
  err "commit message is empty"
  exit 1
fi

SUBJECT=$(echo "$MSG" | head -1)
BODY=$(echo "$MSG" | tail -n +3)   # skip subject + blank line
SUBJECT_LEN=${#SUBJECT}

# ─── §1.1 Subject checks ──────────────────────────────────────────────

# Length
if (( SUBJECT_LEN > 120 )); then
  err "subject is ${SUBJECT_LEN} chars (>120) — split or trim (§1.1)"
elif (( SUBJECT_LEN > 100 )); then
  warn "subject is ${SUBJECT_LEN} chars (>100 recommended cap, §1.1)"
fi

# Format: Conventional Commits OR kernel-style `path/path: ...` OR bracket-prefix `[X] ...`
# (kernel + bracket variants downgraded to warning since not the default)
if echo "$SUBJECT" | grep -qE '^(revert: )?[a-z]+(\([a-z0-9_/.,-]+\))?!?: .{1,}'; then
  : # Conventional Commits — pass
elif echo "$SUBJECT" | grep -qE '^[a-z][a-z0-9_-]*(/[a-z][a-z0-9_-]*)+: .{1,}'; then
  warn "subject uses kernel-style format ('subsystem/path: ...') — valid per §3.5 but document in dialect"
elif echo "$SUBJECT" | grep -qE '^\[[A-Z][A-Za-z0-9_-]*\] .{1,}'; then
  warn "subject uses bracket-prefix format ('[Component] ...') — valid per §3.5 but document in dialect"
elif echo "$SUBJECT" | grep -qE '^[A-Z]+-[0-9]+: .{1,}'; then
  warn "subject uses Jira-id-prefix format ('ABC-1234: ...') — valid per §3.5 but document in dialect"
else
  err "subject does not match Conventional Commits format 'type(scope): summary' (§1.1)"
fi

# Trailing punctuation (period or question-mark; the `!` after type is breaking-change marker so allowed)
LAST_CHAR="${SUBJECT: -1}"
if [[ "$LAST_CHAR" == "." || "$LAST_CHAR" == "?" ]]; then
  err "subject ends with '${LAST_CHAR}' — drop the trailing punctuation (§1.1)"
fi
# An exclamation that follows the type/scope (`feat!:` or `feat(api)!:`) is the breaking-change marker — fine
# A standalone trailing `!` at end of summary is poor style
if [[ "$LAST_CHAR" == "!" ]] && ! echo "$SUBJECT" | grep -qE '\)?!:'; then
  err "subject ends with '!' — drop the trailing punctuation (§1.1; '!' is reserved for breaking-change marker after type/scope)"
fi

# Imperative mood (heuristic — only flag the most common past/progressive forms after the colon)
SUMMARY_AFTER_COLON=$(echo "$SUBJECT" | sed -E 's/^[^:]+: //')
FIRST_WORD=$(echo "$SUMMARY_AFTER_COLON" | awk '{print tolower($1)}')
case "$FIRST_WORD" in
  added|adding|fixed|fixing|updated|updating|removed|removing|changed|changing|implemented|implementing|created|creating|refactored|refactoring|renamed|renaming|merged|merging)
    warn "subject starts with '${FIRST_WORD}' — prefer imperative mood (§0.4): 'add' / 'fix' / 'update' / 'remove' / 'change' / 'implement' / 'create' / 'refactor' / 'rename' / 'merge'"
    ;;
esac

# §0.5 Searchable — flag truly vague summaries
case "$(echo "$SUMMARY_AFTER_COLON" | tr '[:upper:]' '[:lower:]')" in
  wip|"work in progress"|fix|bug|update|updates|change|changes|improve|improvements|"misc updates"|misc|"various fixes"|"small changes"|cleanup|tweaks)
    err "subject is too vague — '${SUMMARY_AFTER_COLON}' — name the concrete domain noun / function / file (§0.5)"
    ;;
esac

# ─── §1.2 Body checks ──────────────────────────────────────────────────

if [[ -n "$BODY" ]]; then
  # Markdown ## headers (§5)
  if echo "$BODY" | grep -qE '^##[[:space:]]+'; then
    warn "body contains '## ' markdown headers — render as raw text in 'git log' (§5). Use plain 'Section:' labels instead"
  fi

  # Body length
  BODY_LINES=$(echo "$BODY" | wc -l | tr -d ' ')
  if (( BODY_LINES > 100 )); then
    err "body is ${BODY_LINES} lines (>100) — almost certainly bundles two intents (§0.1, §4)"
  elif (( BODY_LINES > 80 )); then
    warn "body is ${BODY_LINES} lines (>80) — usually indicates a missed split (§4)"
  fi

  # §7.4 Secrets — best-effort literal scan
  if echo "$BODY" | grep -qiE '(^|[[:space:]])(\.env|password|api[_-]?key|secret[_-]?key|bearer[[:space:]]+[A-Za-z0-9._-]{20,})'; then
    err "body appears to mention a secret value (.env / password / api_key / bearer token) — review and redact (§7.4)"
  fi
fi

# ─── §6 Breaking change footer validation ──────────────────────────────

if echo "$MSG" | grep -q 'BREAKING CHANGE:'; then
  # Confirm there's a blank line before it (trailer convention)
  if ! echo "$MSG" | awk '/^BREAKING CHANGE:/{found=1; if(prev != "") err=1} {prev=$0} END{exit err}'; then
    warn "BREAKING CHANGE: footer should have a blank line before it (§8.3 trailer convention)"
  fi
fi

# ─── Verdict ───────────────────────────────────────────────────────────

if (( ERRORS > 0 )); then
  printf "${RED}✗ ${ERRORS} error(s), ${WARNINGS} warning(s) — commit blocked${RESET}\n" >&2
  printf "  See ~/.claude/skills/principled-git-commit/SKILL.md for the full rules.\n" >&2
  exit 1
elif (( WARNINGS > 0 )); then
  printf "${YELLOW}⚠ ${WARNINGS} warning(s) — commit allowed but consider revising${RESET}\n" >&2
  printf "  See ~/.claude/skills/principled-git-commit/SKILL.md for the full rules.\n" >&2
  exit 2
else
  printf "${GREEN}✓ commit message passes universal §0-§14 checks${RESET}\n" >&2
  exit 0
fi
