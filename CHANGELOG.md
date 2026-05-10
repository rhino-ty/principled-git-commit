# Changelog

All notable changes to this skill are recorded here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The universal layer (Conventional Commits 1.0.0, Tim Pope 2008 imperative
rules, `awesome-copilot/git-commit` workflow patterns, `git interpret-trailers`
trailer format) is upstream-stable, so most changes here will be about
empirical refinements (length sweet-spot data, anti-pattern catalog) and
project-dialect tooling (template, scaffold script, analyze-history script).

## [0.1.1] — 2026-05-11

### Changed

- Renamed from `commit-skill` to `principled-git-commit`. Plain
  `commit-skill` undersold the methodology layer (5 founding principles +
  4-reader rationale + 5-step workflow + dialect scaffolding) and
  collided semantically with the bare `commit` type-name used inside
  the frontmatter `name:` field. The new name communicates that the
  skill bundles principles, not just a format spec.
- All paths and install instructions updated:
  `npx skills add rhino-ty/principled-git-commit`
  `~/.claude/skills/principled-git-commit/`
- SKILL.md frontmatter `name:` updated from `commit` to
  `principled-git-commit` so it matches the repo and skill names of
  sibling rhino-ty skills (apca-contrast / web-project-plan / etc.).

### Migration

If you installed v0.1.0 under the old name, migrate with:

```bash
npx skills remove commit
npx skills add rhino-ty/principled-git-commit -g
```

Skill content (SKILL.md §0-§14) is unchanged; only naming moves.

## [0.1.0] — 2026-05-10

### Added

- Universal SKILL.md (548 lines) extracted from a 612-line TTiRingGo
  `docs/references/COMMIT.md` after a 200-commit empirical study.
- §0 Principles — 4 readers (`git log` scanner / `git blame` tracer /
  `git bisect` hunter / AI agent) plus 5 principles (atomic /
  leaves-repo-green / why-over-what / imperative / searchable). Each
  principle ships with a reader-grounded `→` rationale line.
- §1 Format — type/scope/summary/body/trailer structure with a
  recommended ≤100-char summary length (deliberately looser than the
  classic 50/72 rule, derived from the empirical avg of 71 chars).
- §2 Types — `feat` / `fix` / `refactor` / `docs` / `style` / `chore` /
  `test` / `perf` / `ci` / `build` / `revert`.
- §3 Scopes — single, sub-scope (`/`), multi-scope (`,`), and
  feature-scope conventions.
- §4 Body length sweet-spots (0-2 / 5-10 / 15-25 / 30-40 / 50-80) with
  the empirical observation that >80 lines almost always indicates a
  missed split.
- §5 Markdown rules — `- ` bullets dominate (981/200 in study), `## `
  headers explicitly avoided as a 5/200 outlier signal (renders raw in
  `git log`).
- §6 Breaking Changes — `!` notation and `BREAKING CHANGE:` footer with
  a "when to flag" decision list.
- §7 Workflow (5-step) — diff inspection / staging strategies (path /
  glob / `-p` hunks / directory) / type decision tree (10-row diff-
  pattern → type mapping) / secrets blocklist (8 risky file patterns
  with grep verification) / pre-commit mental checklist.
- §8 Trailers — standard (`Co-authored-by:` / `Refs:` / `Closes:` /
  `Reviewed-by:` / `Signed-off-by:` / `BREAKING CHANGE:`) plus
  project-dialect extension hook.
- §9 Amend / fixup rules — strict policy against amending published
  commits, and `fixup!` / autosquash flow for unpublished work.
- §10 Reverts — `revert: <original>` format with mandatory reason field.
- §11 Anti-patterns — 12 entries cross-referenced to the principle each
  violates.
- §12 Quick reference card.
- §13 Project Dialect — defines what belongs in the skill vs in the
  per-project `docs/references/COMMIT.md`, plus the runtime loading
  order (skill → dialect → scaffold offer).
- Korean prose variant under `lang/ko/SKILL.md` for Korean-first
  readers; the convention itself stays English-default regardless of
  variant.
- `templates/DIALECT.template.md` — placeholder skeleton.
- `templates/DIALECT.example.md` — filled example using TTiRingGo (9
  Korean proper nouns, scope catalog from a real 200-commit study,
  PDCA Phase auto-commit policy, b8792c0 cited as a cautionary tale).
- `scripts/analyze-history.sh` — portable bash tool that emits top
  type(scope) frequencies, sub/multi-scope detections, length stats,
  and `## ` header outlier counts for any git repo.
- `scripts/scaffold-dialect.sh` — interactive generator that prompts
  for project name, domain proper nouns, optional history embedding,
  workflow integration (PDCA / Linear / Jira / none), and custom
  trailers, then renders the template into
  `<cwd>/docs/references/COMMIT.md`.
- `references/REFERENCES.md` — full source attribution beyond SKILL.md
  §14, including a section explaining why "AI agent" is treated as a
  first-class reader (the skill's distinguishing contribution beyond
  the spec sources it builds on).
- `examples/good-commits.md` — 6 annotated good commits (single fix /
  fix with focused body / module-scale PDCA Phase commit / PDCA wrap /
  breaking change / revert) plus 5 anti-pattern examples.
- README.md with install instructions (global vs project) and
  AI-as-first-class-reader rationale.
- MIT license.
