#!/usr/bin/env bash
# analyze-history.sh — derive a scope catalog from a repo's git log
#
# Usage:
#   ./analyze-history.sh [N]
#
# N = number of commits to analyze (default: 200)
#
# Outputs (to stdout):
#   - Top type(scope) frequencies
#   - Sub-scope (slash-separated) detected
#   - Multi-scope (comma-separated) detected
#   - Body length statistics (avg / max / >50-line outliers)
#   - Markdown header (## ) usage in bodies (should be near zero)
#
# Exit non-zero if not in a git repo.

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository" >&2
  exit 1
fi

N="${1:-200}"

echo "=== git log analysis (last $N commits, no merges) ==="
echo

echo "--- Top type(scope) ---"
git log -n "$N" --no-merges --format='%s' \
  | grep -oE '^[a-z]+\([^)]+\)' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -25
echo

echo "--- Sub-scopes (slash-separated) ---"
git log -n "$N" --no-merges --format='%s' \
  | grep -oE '^[a-z]+\([^)]*/[^)]*\)' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -15
echo

echo "--- Multi-scopes (comma-separated) ---"
git log -n "$N" --no-merges --format='%s' \
  | grep -oE '^[a-z]+\([^)]*,[^)]*\)' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -15
echo

echo "--- Subject length stats ---"
git log -n "$N" --no-merges --format='%s' \
  | awk '{print length}' \
  | awk 'BEGIN{c=0; s=0; min=999} {c++; s+=$1; if($1>max)max=$1; if($1<min)min=$1} END{print "  count="c, "min="min, "avg="int(s/c), "max="max}'
echo

echo "--- Body length stats (lines) ---"
git log -n "$N" --no-merges --format='%H' \
  | while read -r h; do
      git log -1 --format='%b' "$h" | wc -l | tr -d ' '
    done \
  | awk 'BEGIN{c=0; s=0; bigs=0} {c++; s+=$1; if($1>max)max=$1; if($1>50)bigs++; if($1==0)empty++} END{print "  count="c, "avg="int(s/c), "max="max, "empty_body="empty, ">50_lines="bigs}'
echo

echo "--- Markdown ## header usage in bodies ---"
hash_count=$(git log -n "$N" --no-merges --format='%b' | grep -c '^## ' || true)
bullet_count=$(git log -n "$N" --no-merges --format='%b' | grep -c '^- ' || true)
echo "  ## headers   : $hash_count  (should be near zero — outlier per universal §5)"
echo "  - bullets    : $bullet_count"
echo

echo "--- Top 10 longest summaries (potential outliers) ---"
git log -n "$N" --no-merges --format='%H %s' \
  | awk '{l=length($0)-41; print l"\t"$0}' \
  | sort -rn \
  | head -10 \
  | awk '{$1=""; sub(/^\t/,""); print}'
echo

echo "Done. Use the type(scope) and sub-scope tables above to fill out"
echo "your project's docs/references/COMMIT.md §2 Scope Catalog."
