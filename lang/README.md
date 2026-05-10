# Language Variants

The skill ships with one prose variant per language. The **convention itself** does not change between variants — English-default body, lowercase summary, imperative mood, and all rules in §0-§14 apply identically. Only the explanation prose differs.

## Available variants

- `en/` — implicit (the top-level `SKILL.md` IS the English variant)
- `ko/SKILL.md` — Korean prose

## Switching

Pass the `lang` arg when triggering the skill:

```
/commit lang=ko
```

Or set globally in your skill config:

```bash
echo 'COMMIT_SKILL_LANG=ko' >> ~/.claude/skills/commit/.config
```

## Why the convention itself stays English

A commit's primary readers (`git log` scanner / `blame` tracer / `bisect` hunter / AI agent) all benefit from a single language baseline. English wins on:

- `git log --grep` cross-cultural reuse
- LLM cross-language model performance (most embedding models are English-strongest)
- Tooling (changelog generators, type inference) trained on English

Project-specific proper nouns (product names, native-language regulatory references) stay in their original script — defined in the project dialect (`docs/references/COMMIT.md`).
