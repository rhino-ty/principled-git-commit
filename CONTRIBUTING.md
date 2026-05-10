# Contributing to principled-git-commit

Thanks for considering a contribution. This skill defines commit conventions, so the skill's own repo eats its own dogfood — every commit here passes the universal §0-§14 rules from `SKILL.md`.

## Before opening a PR

1. **Read `SKILL.md` §0 Principles** — the founding 5 (atomic / leaves-repo-green / why-over-what / imperative / searchable). Every PR review starts there.
2. **Run the validator on your commits**:
   ```bash
   git log --format='%B' main..HEAD | while read -d '' commit_msg; do
     printf '%s' "$commit_msg" | scripts/validate-commit-msg.sh --stdin
   done
   ```
   Or wire it as a `commit-msg` hook for live feedback:
   ```bash
   ln -sf "$(pwd)/scripts/validate-commit-msg.sh" .git/hooks/commit-msg
   ```
3. **CI will re-run the validator on every commit in your PR**. PRs with commits that fail universal rules are auto-blocked. See `.github/workflows/validate-commits.yml`.

## Scope of contributions we welcome

Most welcome:

- **Bug fixes** in scripts (`validate-commit-msg.sh`, `analyze-history.sh`, `scaffold-dialect.sh`)
- **New examples** in `examples/good-commits.md` drawn from real-world public OSS commits (with attribution to the source repo, not verbatim copies)
- **New language variants** under `lang/<code>/SKILL.md` — keep the convention rules English-default, only translate prose
- **Coverage gaps** in SKILL.md sections backed by empirical evidence (cite a study or ≥30 commit corpus)
- **Tests** — currently we rely on smoke tests and live CI, additional shell-level tests for the validators welcome

Less welcome (open an issue first to discuss):

- **New principles in §0** — the founding 5 are a hard contract. New principles should be debated in an issue with empirical backing
- **Adding more types beyond Conventional Commits 1.0.0** — we want to stay close to the spec
- **Removing or weakening anti-patterns** — these come from real failures; need a strong case
- **Breaking-change rewrites** of the SKILL.md frontmatter — coordinate with downstream installs first

Out of scope:

- **Project-specific dialect content** — that belongs in your own `docs/references/COMMIT.md`, not in this skill
- **Translation of existing project's dialect** — this skill is the universal layer

## Commit conventions for this repo

The same as `SKILL.md` defines — but a few specific notes for this repo's scopes:

| Scope | When to use |
|---|---|
| `feat(skill)` | adding new principle / section / capability to SKILL.md |
| `feat(scripts)` | new or extended shell script |
| `chore(skill)` | metadata, frontmatter, version bumps |
| `docs(skill)` | clarifying existing rules, no new policy |
| `docs(refs)` | adding citations to `references/REFERENCES.md` |
| `feat(lang/<code>)` | new language variant |
| `fix(scripts)` | script bug fix |
| `chore(ci)` | GitHub Actions changes |

## Versioning

This repo follows Semantic Versioning:

- **MAJOR**: breaking changes to SKILL.md frontmatter (`name:`, `description:`), removal of universal sections, or removal of script entry points
- **MINOR**: new sections, new types, new principles, new scripts, new language variants
- **PATCH**: clarifications, example swaps, prose polish, script bug fixes

Bump `metadata.version` in `SKILL.md` AND `lang/ko/SKILL.md` AND add a `CHANGELOG.md` entry. The validator and CI do not enforce version bumps — that's a manual courtesy for downstream `npx skills update`.

## Testing changes

```bash
# Lint your own commits
git log --format='%B' main..HEAD | scripts/validate-commit-msg.sh --stdin

# Run analyze-history.sh against this repo
scripts/analyze-history.sh 50

# Test scaffold-dialect.sh in a throwaway dir
( mkdir -p /tmp/test-scaffold && cd /tmp/test-scaffold && git init -q && \
  echo "test" > a.txt && git add a.txt && git commit -qm "feat(test): seed" && \
  bash ~/.claude/skills/principled-git-commit/scripts/scaffold-dialect.sh )
```

## License

By contributing, you agree your contributions ship under the project's MIT license (see `LICENSE`).
