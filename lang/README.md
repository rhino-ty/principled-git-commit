# Language Variants

The skill ships with one prose variant per language. The **convention itself** does not change between variants — English-default body, lowercase summary, imperative mood, and all rules in §0-§14 apply identically. Only the explanation prose differs.

## Available variants

- `en/` — implicit (the top-level `SKILL.md` IS the English variant)
- `ko/SKILL.md` — Korean prose

## Switching

Two practical ways to use the Korean variant:

### Option A — Manual reference

When you want to read the founding principles in Korean, open `lang/ko/SKILL.md` directly. The agent loads the top-level English `SKILL.md` by default; the Korean variant is a complementary reading aid for human contributors, not a separate trigger target.

### Option B — Replace at install time

If you prefer the Korean variant to be the agent's primary instruction file, swap it in after install:

```bash
cd ~/.claude/skills/commit
mv SKILL.md lang/en/SKILL.md
mkdir -p lang/en
ln -sf lang/ko/SKILL.md SKILL.md
```

(Or copy `lang/ko/SKILL.md` over the top-level `SKILL.md` directly.)

The agent will then load Korean prose at trigger time. The convention itself does not change — bodies are still English-default, summaries are still lowercase imperative, etc. Only the explanation prose is Korean.

## Why the convention itself stays English

A commit's primary readers (`git log` scanner / `blame` tracer / `bisect` hunter / AI agent) all benefit from a single language baseline. English wins on:

- `git log --grep` cross-cultural reuse
- LLM cross-language model performance (most embedding models are English-strongest)
- Tooling (changelog generators, type inference) trained on English

Project-specific proper nouns (product names, native-language regulatory references) stay in their original script — defined in the project dialect (`docs/references/COMMIT.md`).
