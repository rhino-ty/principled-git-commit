#!/usr/bin/env bash
# scaffold-dialect.sh — generate a project-specific COMMIT.md dialect file
#
# Usage:
#   ./scaffold-dialect.sh [output-path]
#
# Default output: <cwd>/docs/references/COMMIT.md
#
# Interactive prompts collect:
#   - Project name
#   - Domain proper nouns (terms that should NOT be translated in commits)
#   - Whether to run analyze-history.sh and embed results
#   - Workflow integration (PDCA / Linear / Jira / none)
#   - Custom trailers
#
# The generated file replaces template placeholders ({{PROJECT_NAME}}, etc.)
# with answers and points users back to the universal SKILL.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$SKILL_DIR/templates/DIALECT.template.md"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: template not found at $TEMPLATE" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository — run from your project root" >&2
  exit 1
fi

OUTPUT_PATH="${1:-docs/references/COMMIT.md}"
OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"

if [[ -f "$OUTPUT_PATH" ]]; then
  echo "WARNING: $OUTPUT_PATH already exists. Overwrite? [y/N]"
  read -r confirm
  [[ "$confirm" != "y" ]] && exit 0
fi

mkdir -p "$OUTPUT_DIR"

# ─── Prompts ──────────────────────────────────────────────────────────

read -rp "Project name: " PROJECT_NAME
PROJECT_NAME="${PROJECT_NAME:-MyProject}"

echo "Domain proper nouns to keep un-translated (comma-separated, blank for none):"
read -r DOMAIN_NOUNS_RAW

read -rp "Run analyze-history.sh and embed scope catalog? [Y/n]: " RUN_ANALYZE
RUN_ANALYZE="${RUN_ANALYZE:-Y}"

read -rp "Workflow integration (pdca / linear / jira / none): " WORKFLOW
WORKFLOW="${WORKFLOW:-none}"

echo "Custom trailers (comma-separated tokens like 'Plan SC,Design Ref,Match Rate', blank for none):"
read -r CUSTOM_TRAILERS_RAW

# ─── Build sections ───────────────────────────────────────────────────

build_domain_nouns() {
  if [[ -z "$DOMAIN_NOUNS_RAW" ]]; then
    echo "_(none — fill in if your project has terms that should not be translated)_"
    return
  fi
  echo "| Term | Why kept |"
  echo "|---|---|"
  IFS=',' read -ra NOUNS <<< "$DOMAIN_NOUNS_RAW"
  for n in "${NOUNS[@]}"; do
    n="$(echo "$n" | xargs)"
    [[ -n "$n" ]] && echo "| \`$n\` | _(describe why this stays un-translated)_ |"
  done
}

build_scope_catalog() {
  if [[ "$RUN_ANALYZE" =~ ^[Yy]$ ]]; then
    echo "Auto-extracted from \`git log\` (last 200 commits) on $(date +%F):"
    echo ""
    echo '```'
    "$SCRIPT_DIR/analyze-history.sh" 200 2>&1 || echo "(analyze-history.sh failed — fill in manually)"
    echo '```'
  else
    echo "_(run \`$SCRIPT_DIR/analyze-history.sh 200\` and paste the output here)_"
  fi
}

build_workflow() {
  case "$WORKFLOW" in
    pdca|PDCA)
      cat <<EOF
This project uses PDCA cycles. Each phase boundary triggers an automatic commit (no user prompt required).

| Phase boundary | Auto-commit | Example summary |
|---|:--:|---|
| Plan document complete | ✅ | \`docs({{feature}}): plan vX.Y (N FRs / M decisions)\` |
| Design document complete | ✅ | \`docs({{feature}}): design Option C — Pragmatic\` |
| Do — each module complete | ✅ | \`feat({{feature}}): Mn — concrete deliverable\` |
| Check (gap analysis) complete | ✅ | \`docs({{feature}}): gap analysis NN%\` |
| iter-N complete | ✅ | \`fix({{feature}}): iter-N — Gap #N close\` |
| Report complete | ✅ | \`docs(pdca): {{feature}} completion report (Match NN%)\` |

User-triggered (still): \`git push\` / force push / branch deletion / interactive rebase.
EOF
      ;;
    linear|Linear)
      cat <<EOF
This project uses Linear. Reference Linear ticket IDs in trailers:

\`\`\`
Refs: ABC-123
Closes: ABC-456
\`\`\`

Auto-commit boundaries: at the close of each Linear status transition (Triage → Backlog → In Progress → In Review → Done).
EOF
      ;;
    jira|Jira)
      cat <<EOF
This project uses Jira. Reference Jira issue keys in summary or trailers:

\`\`\`
feat(API-123): add export endpoint
Refs: API-456
\`\`\`
EOF
      ;;
    *)
      echo "_(no automated workflow — commits are user-triggered as needed)_"
      ;;
  esac
}

build_trailers() {
  if [[ -z "$CUSTOM_TRAILERS_RAW" ]]; then
    echo "_(no project-specific trailers beyond standard \`Refs:\` / \`Closes:\` / \`Co-authored-by:\`)_"
    return
  fi
  echo "| Token | Purpose | Example value |"
  echo "|---|---|---|"
  IFS=',' read -ra TRAILERS <<< "$CUSTOM_TRAILERS_RAW"
  for t in "${TRAILERS[@]}"; do
    t="$(echo "$t" | xargs)"
    [[ -n "$t" ]] && echo "| \`$t:\` | _(describe purpose)_ | _(example)_ |"
  done
}

# ─── Render ────────────────────────────────────────────────────────────

DATE=$(date +%F)

DOMAIN_NOUNS_BLOCK=$(build_domain_nouns)
SCOPE_CATALOG_BLOCK=$(build_scope_catalog)
WORKFLOW_BLOCK=$(build_workflow)
TRAILERS_BLOCK=$(build_trailers)

# Use Perl for safe multi-line replacement (sed struggles with newlines portably)
perl -i.bak -pe '
  BEGIN {
    $project = $ENV{PROJECT_NAME};
    $date    = $ENV{DATE};
  }
  s/\{\{PROJECT_NAME\}\}/$project/g;
  s/\{\{DATE\}\}/$date/g;
  s/\{\{SKILL_VERSION\}\}/0.1.0/g;
' \
  PROJECT_NAME="$PROJECT_NAME" DATE="$DATE" \
  -- "$TEMPLATE" >/dev/null 2>&1 || true

# Render — use awk to substitute the larger blocks (Perl one-liner above
# only handles short single-line tokens reliably across shells)
TMP_OUT="$(mktemp)"
awk -v pn="$PROJECT_NAME" \
    -v dn="$DOMAIN_NOUNS_BLOCK" \
    -v sc="$SCOPE_CATALOG_BLOCK" \
    -v wf="$WORKFLOW_BLOCK" \
    -v ct="$TRAILERS_BLOCK" \
    -v dt="$DATE" \
    -v sv="0.1.0" \
'
{
  gsub(/\{\{PROJECT_NAME\}\}/, pn);
  gsub(/\{\{DATE\}\}/, dt);
  gsub(/\{\{SKILL_VERSION\}\}/, sv);
  if (/\{\{DOMAIN_NOUNS\}\}/) { print dn; next }
  if (/\{\{SCOPE_CATALOG\}\}/) { print sc; next }
  if (/\{\{WORKFLOW_INTEGRATION\}\}/) { print wf; next }
  if (/\{\{CUSTOM_TRAILERS\}\}/) { print ct; next }
  if (/\{\{SUB_SCOPES\}\}/) { print "_(fill from analyze-history.sh sub-scopes section)_"; next }
  if (/\{\{MULTI_SCOPE_EXAMPLES\}\}/) { print "_(fill from analyze-history.sh multi-scopes section)_"; next }
  if (/\{\{FEATURE_SCOPES\}\}/) { print "_(list long-running feature names if applicable)_"; next }
  if (/\{\{ACTIVE_TYPES\}\}/) { print "_(list types your project actually uses)_"; next }
  if (/\{\{INACTIVE_TYPES\}\}/) { print "_(document why each unused type is omitted)_"; next }
  if (/\{\{EXAMPLES\}\}/) { print "_(paste 2-3 good commits from this repo with annotations explaining why they work)_"; next }
  if (/\{\{PROJECT_ANTI_PATTERNS\}\}/) { print "_(list project-specific patterns you have learned to avoid — e.g. translating proper nouns)_"; next }
  print
}
' "$TEMPLATE" > "$TMP_OUT"

mv "$TMP_OUT" "$OUTPUT_PATH"
rm -f "$TEMPLATE.bak"

echo
echo "✓ Dialect file written to: $OUTPUT_PATH"
echo
echo "Next steps:"
echo "  1. Review the file and fill in any _(italicized placeholders)_"
echo "  2. Add a pointer in your project's CLAUDE.md (or equivalent):"
echo "     | Commit conventions (universal) | ~/.claude/skills/principled-git-commit/SKILL.md |"
echo "     | Commit dialect (project)       | docs/references/COMMIT.md       |"
echo "  3. Commit the dialect file:"
echo "     git add $OUTPUT_PATH"
echo "     git commit -m 'docs(refs): add commit dialect (extends principled-git-commit universal layer)'"
