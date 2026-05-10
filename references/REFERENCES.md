# Source Attribution & References

## Primary specifications

- **[Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)** — `type(scope): summary` format, `!` and `BREAKING CHANGE:` notation, type vocabulary (`feat`, `fix`, `chore`, etc.). The skill's §1, §2, §6 derive from this spec.

- **Tim Pope, ["A Note About Git Commit Messages"](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)** (2008) — imperative mood ("If applied, this commit will..."), summary/body separation. The skill's §0.4 quotes this directly.

- **`git interpret-trailers(1)`** ([docs](https://git-scm.com/docs/git-interpret-trailers)) — trailer block format (`Token: value`), parsing semantics. The skill's §8 follows this convention.

## Derived patterns

- **`github/awesome-copilot@git-commit`** (29.6K installs as of 2026-05) — the workflow-step structure (analyze diff → stage → message), type detection through diff inspection, and explicit "never commit secrets" blocklist. Absorbed into §7 of the skill.

  Original at: <https://skills.sh/github/awesome-copilot/git-commit>

- **`github/awesome-copilot@conventional-commit`** (11.3K installs) — XML structure for prompt-driven commit generation (not used directly; the skill prefers prose-driven format).

## Empirical sources

- **Private-project 200-commit study (2026-05)** — supplied:
  - Length sweet-spot data: avg summary 71 chars (max 116), avg body 16 lines (max 84)
  - Markdown header outlier: 5 commits used `## ` headers, 195 did not. The skill's §5 codifies "no `##` in body" partly because of this 2.5%-of-corpus signal
  - Sub-scope (`/`) and multi-scope (`,`) usage frequencies — both observed in the wild and codified in §3.2 / §3.3
  - Module tag `(Module N)` convention — observed in long-running cycles, codified in DIALECT template §4.1

## Reading list (deeper context)

- Linus Torvalds, ["A note from Linus on commit messages"](https://github.com/torvalds/linux/pull/17#issuecomment-5654674) — bisect culture
- Chris Beams, ["How to Write a Git Commit Message"](https://chris.beams.io/posts/git-commit/) — popular interpretation of Tim Pope's rules
- Karma project, ["Git Commit Message Conventions"](http://karma-runner.github.io/0.10/dev/git-commit-msg.html) — early Conventional Commits ancestor
- Anthropic skills documentation — <https://skills.sh/>

## Why "AI agent" is treated as a first-class reader

This skill's §0 lists four readers: `git log` scanner, `git blame` tracer, `git bisect` hunter, and **AI agent**. The fourth is novel relative to Tim Pope (2008) and Conventional Commits (2016), but matches the way modern repositories are actually consumed:

- Claude Code, GitHub Copilot, Cursor, and similar agents all consult `git log` / `git blame` / `git show` to rebuild context after `/clear` or session restart
- Changelog generation, PR summarization, and "what changed in this release?" queries are increasingly LLM-mediated
- Natural-language history search ("where did we add the partial-unique constraint?") depends on embedding retrieval over commit messages

Every principle in §0 explicitly calls out the AI implication alongside the human one. This is the skill's distinguishing contribution beyond the spec sources above.
