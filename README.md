# principled-git-commit

> Claude Code skill: Conventional Commits + 5 founding principles + 5-step workflow + project-dialect scaffolding. Treats commits as durable history that serves four readers — `git log` scanners, `git blame` tracers, `git bisect` hunters, and **AI agents**.

[![Made with](https://img.shields.io/badge/Made%20with-Claude%20Skills-blueviolet)](https://docs.claude.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

Most commit conventions stop at "use Conventional Commits." This skill adds:

- **Five founding principles** (atomic, leaves-repo-green, why-over-what, imperative, searchable) — each with a one-line rationale tying back to a concrete reader scenario
- **Five-step commit workflow** (diff inspection → staging → type-decision tree → secrets blocklist → mental checklist) absorbed from `awesome-copilot/git-commit` patterns
- **Breaking change / revert / amend protocols** so history stays bisect-friendly
- **Anti-patterns** with concrete remediation (vague summaries, `##` headers in body, `git add -A`, amending published commits, etc.)
- **Project dialect scaffolder** — generates a per-project `docs/references/COMMIT.md` skeleton for project-specific extensions (native-language domain nouns, custom trailers like `Refs: #1234` / `Flag:` / `Plan SC:`, workflow hooks like PDCA / Linear / Jira / squash-merge PR, scope catalogs derived from actual `git log` analysis)

The skill is **content-separated**: universal rules ship inside the skill, project-specific dialect lives in the project's `docs/references/`. This lets one global install serve every repo while each repo retains its own dialect.

## Why "AI agent" is a first-class reader

Modern git history is consumed by LLM agents at least as often as by humans — for `/clear` context rebuild, PR review, changelog generation, and natural-language history queries. AI readers depend heavily on:

- **Atomic commits** so a one-sentence summary captures the change without conflating intents
- **Searchable keywords** (concrete nouns, function names, file paths) so embedding search hits the right commit
- **English body by default** so cross-cultural LLM models perform consistently
- **Consistent trailers** (`Refs:`, `BREAKING CHANGE:`, custom dialect trailers) for graph navigation

Every principle in this skill calls out the AI-reader implication alongside the human-reader implication.

## Install

```bash
npx skills add rhino-ty/principled-git-commit
```

Auto-loads on next Claude Code session and triggers on keywords: `commit`, `git commit`, `stage`, `commit message`, `커밋`.

To verify:

```bash
ls ~/.claude/skills/principled-git-commit/
# SKILL.md  lang/  templates/  scripts/  references/  examples/
```

## Project-level install

If a team needs to pin the skill version per repo (and have it land for new clones automatically), install at project level instead:

```bash
cd <project>
npx skills add rhino-ty/principled-git-commit --project
```

This places the skill in `<project>/.claude/skills/principled-git-commit/` (repo-tracked). Project install **overrides** any global install of the same skill.

## Generate a project dialect

When you start a fresh project (or import this skill into an existing one), let the skill scaffold the dialect file:

```bash
cd <project>
~/.claude/skills/principled-git-commit/scripts/scaffold-dialect.sh
```

This drops `docs/references/COMMIT.md` (a project-specific extension that points back to the skill) populated with:

- A pointer to this skill as the universal source of truth
- Slots for domain proper nouns (e.g., Korean product names that should stay un-translated)
- A scope catalog auto-extracted from `git log` (frequency-ranked, top 200 commits)
- Slots for custom trailers (`Plan SC`, `Refs:`, `Match Rate`, etc.)
- Optional workflow hooks (PDCA / Linear / Jira-style auto-commit boundaries)

Edit the result to match your project. The skill loads both `SKILL.md` and the project's dialect file at trigger time.

## Language

The skill ships with English prose in `SKILL.md` and an optional Korean prose variant under `lang/ko/SKILL.md`. Toggle via the skill's `args.lang` parameter or by editing the symlink in your install — see `lang/README.md`.

The **convention itself** (English-default body, lowercase summary, imperative mood) does not change between language variants. Only the explanation prose differs.

## Layout

```
principled-git-commit/
├── SKILL.md                      # Universal conventions (English)
├── lang/
│   └── ko/SKILL.md               # Korean prose variant
├── templates/
│   ├── DIALECT.template.md       # Project dialect skeleton
│   └── DIALECT.example.md        # Filled example (Acme Cloud — fictional pnpm monorepo + Linear + LaunchDarkly)
├── scripts/
│   ├── scaffold-dialect.sh       # Interactive dialect generator
│   └── analyze-history.sh        # git log → scope catalog
├── references/
│   └── REFERENCES.md             # Source attribution (Conventional Commits, Tim Pope, awesome-copilot)
└── examples/
    └── good-commits.md           # Annotated good/bad real commits
```

## Source attribution

This skill stands on the shoulders of:

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/)
- Tim Pope, ["A Note About Git Commit Messages"](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- `github/awesome-copilot@git-commit` (workflow patterns, type detection, secrets blocklist)
- `git interpret-trailers` (1.8.13+) for footer parsing

Plus an empirical 200-commit log analysis that produced the length sweet-spot (avg 71-char summary, 16-line body) and the observation that `##` markdown headers in commit bodies are a 2.5%-of-commits outlier (and therefore noise rather than signal).
