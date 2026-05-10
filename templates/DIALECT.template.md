# {{PROJECT_NAME}} — Commit Dialect

> Project-specific extensions to commit conventions. The **universal layer** lives in `~/.claude/skills/principled-git-commit/SKILL.md` (or `<project>/.claude/skills/principled-git-commit/SKILL.md` for project-level installs). Read that first.
>
> This dialect file extends the universal layer with **project-specific facts only** — domain proper nouns, custom scope catalog, custom trailers, workflow integrations. It never overrides universal principles or rules.

---

## 1. Domain Proper Nouns

Terms that should NOT be translated to English. Keep in original script in summary and body.

{{DOMAIN_NOUNS}}

> Example entries:
> - `친구톡` — KakaoTalk friend message channel
> - `알림톡` — KakaoTalk notification channel
> - `발신번호` — sender number (regulatory term)

---

## 2. Scope Catalog (200-commit empirical)

Top-frequency scopes from this repo's actual `git log`. Keep this section regenerated periodically via `~/.claude/skills/principled-git-commit/scripts/analyze-history.sh`.

{{SCOPE_CATALOG}}

> Example entries:
> | Scope | Frequency | Description |
> |---|:--:|---|
> | `client` | 87 | Client-side code (Next.js app + components) |
> | `server` | 62 | NestJS server modules |
> | `messages` | 24 | Messaging domain (compose / send / channels) |
> | `pdca` | 13 | PDCA cycle artifacts (plan / design / check / report) |

### 2.1 Sub-scopes in active use

`{{SUB_SCOPES}}`

### 2.2 Multi-scope examples

`{{MULTI_SCOPE_EXAMPLES}}`

### 2.3 Feature-scopes (long-running cycles)

`{{FEATURE_SCOPES}}`

---

## 3. Custom Trailers

Project-specific trailer tokens used in this repo. Stock git tooling won't auto-parse these but they remain grep-friendly and human-meaningful.

{{CUSTOM_TRAILERS}}

> Example entries:
> | Token | Purpose | Example value |
> |---|---|---|
> | `Plan SC:` | Plan-document Success Criteria covered | `SNM-001~004` |
> | `Design Ref:` | Design-document section pointer | `§2.1, §5.4` |
> | `Match Rate:` | Gap analysis match score | `98.0% (raw 89.4%, iter-1)` |
> | `Refs:` | Issue / commit cross-link | `#42` or `b8792c0` |

---

## 4. Workflow Integration

Auto-commit boundaries — phases at which the commit boundary is automatic, not user-triggered. Universal §0.1 (atomic) still governs each commit.

{{WORKFLOW_INTEGRATION}}

> Example for PDCA-driven projects:
>
> | Phase boundary | Auto-commit | Example summary |
> |---|:--:|---|
> | Plan document complete | ✅ | `docs({{feature}}): plan v1.0 (N FRs / M decisions)` |
> | Design document complete | ✅ | `docs({{feature}}): design Option C — Pragmatic` |
> | Do — each module complete | ✅ | `feat({{feature}}): Mn — concrete deliverable` |
> | Check (gap analysis) complete | ✅ | `docs({{feature}}): gap analysis NN%` |
> | iter-N complete | ✅ | `fix({{feature}}): iter-N — Gap #N close` |
> | Report complete | ✅ | `docs(pdca): {{feature}} completion report (Match NN%)` |
>
> User-triggered (still): `git push` / `git push --force` / branch deletion / interactive rebase / history rewrite.

---

## 5. Type Usage Policy

Universal types used in this project: {{ACTIVE_TYPES}}

Universal types **not used** in this project: {{INACTIVE_TYPES}}

> Document why a type is unused (e.g., "no `perf` because no benchmark suite") so future contributors know.

---

## 6. Project-Specific Examples

Annotated good commits from this repo's history:

{{EXAMPLES}}

> Example:
>
> ```
> feat(sender-number-mgmt): M1 schema + INACTIVE seed
>
> PDCA Phase=Do. ★ invariant via partial UNIQUE; INACTIVE via 공통코드.
>
> - server/src/db/schema/sender-numbers.schema.ts: +alias varchar(30),
>   +isDefault boolean, +partial UNIQUE `WHERE is_default = true`
> ...
>
> Plan SC: SNM-001~004
> ```
>
> Why this works: scope = feature name (long-running cycle), `PDCA Phase=Do` makes the workflow context grep-able, `Plan SC` trailer cross-links to the plan document. Each bullet names the file + the change concept (not just file path).

---

## 7. Anti-Patterns Specific to This Project

In addition to universal §11 anti-patterns:

{{PROJECT_ANTI_PATTERNS}}

> Example entries (TTiRingGo case):
> - 80+ line commit body bundling `plan + design + M1 + M2` (predates Phase-auto-commit policy — see `b8792c0` for the cautionary tale)
> - Translating `친구톡` → `friendtalk` (loses regulatory specificity, breaks grep)

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | {{DATE}} | Initial dialect scaffolded by `principled-git-commit@{{SKILL_VERSION}}` | scaffold |
