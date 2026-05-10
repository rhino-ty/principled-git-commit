# {{PROJECT_NAME}} — Commit Dialect

> Project-specific extensions to commit conventions. The **universal layer** lives in `~/.claude/skills/principled-git-commit/SKILL.md` (or `<project>/.claude/skills/principled-git-commit/SKILL.md` for project-level installs). Read that first.
>
> This dialect file extends the universal layer with **project-specific facts only** — domain proper nouns, custom scope catalog, custom trailers, workflow integrations. It never overrides universal principles or rules.

---

## 1. Domain Proper Nouns

Terms that should NOT be translated to English. Keep in original script in summary and body.

{{DOMAIN_NOUNS}}

> Example entries (mix-and-match — pick whatever fits your project):
> - **Brand names** — `BoardKit`, `Acme Pay`, `LDAP-Bridge`
> - **Native-language regulatory terms** — `친구톡` (KakaoTalk friend channel), `정통망법` (Korean privacy statute), `LGPD` (Brazilian privacy law)
> - **Native-language product names** — `Mercado Libre`, `Yahoo!知恵袋`
> - **Internal service names that should stay verbatim** — `redis-shard-router`, `payment-gateway-v2`

---

## 2. Scope Catalog (200-commit empirical)

Top-frequency scopes from this repo's actual `git log`. Keep this section regenerated periodically via `~/.claude/skills/principled-git-commit/scripts/analyze-history.sh`.

{{SCOPE_CATALOG}}

> Example entries (replace with your `git log` analysis output):
> | Scope | Frequency | Description |
> |---|:--:|---|
> | `apps/dashboard` | 24 | Next.js dashboard app |
> | `packages/ui` | 31 | Shared component library |
> | `packages/db` | 14 | Drizzle / Prisma schema + migrations |
> | `infra` | 11 | Terraform + GitHub Actions |
> | `docs` | 16 | repo-level docs |
>
> Run `~/.claude/skills/principled-git-commit/scripts/analyze-history.sh 200` to derive your real catalog.

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

> Example entries (pick whatever your team uses consistently):
> | Token | Purpose | Example value |
> |---|---|---|
> | `Refs:` | Linear / Jira / GitHub issue reference | `#42` or `ACM-1234` |
> | `Closes:` | Auto-close issue on merge | `Closes: #42` |
> | `Flag:` | Feature-flag involved | `Flag: billing-invoice-pdf-v2` |
> | `Storybook:` | Storybook story added/changed | `Storybook: components-button--all-variants` |
> | `Rollout:` | Phased rollout plan | `Rollout: 5% → 50% → 100%` |
> | `Plan SC:` | PDCA Plan Success Criteria | `Plan SC: ABC-001~004` |
> | `Design Ref:` | Design-document section pointer | `§2.1, §5.4` |
> | `Match Rate:` | PDCA gap-analysis score | `98.0%` |
> | `Fixes:` | Kernel-style "fix-of-prior-commit" pointer | `Fixes: abc123de ("subsystem: refactor X")` |
> | `Reported-by:` | Kernel-style report attribution | `Reported-by: Name <email>` |

---

## 4. Workflow Integration

Auto-commit boundaries — phases at which the commit boundary is automatic, not user-triggered. Universal §0.1 (atomic) still governs each commit.

{{WORKFLOW_INTEGRATION}}

> Example A — **PDCA-driven projects** (Plan / Design / Do / Check / Act phases):
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
> Example B — **Squash-merge PR projects** (GitHub flow with strict commit policy):
>
> | Boundary | Auto-commit | Notes |
> |---|:--:|---|
> | Inside feature branch | manual WIP commits | individual commits may not need to build |
> | PR squash at merge | ✅ (via `gh pr merge --squash`) | the squashed message MUST follow universal §1; CI gates the merge |
>
> Example C — **Trunk-based with feature flags** (no long-running branches):
>
> | Boundary | Auto-commit | Notes |
> |---|:--:|---|
> | Each logical change to main | manual | every commit ships to production behind a flag |
> | Flag flip (rollout milestone) | ✅ | `chore(flag): bump billing-invoice-pdf-v2 to 50%` |
>
> User-triggered regardless of project style: `git push --force` / branch deletion / interactive rebase / history rewrite.

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
> feat(packages/ui): add <DataTable> with virtualization (Closes ACM-1234)
>
> Adds a virtualized table component for the dashboard inventory page —
> the existing <Table> rendered all rows synchronously, which OOMed at
> ~10k rows on low-memory devices. Uses TanStack Table v8 +
> react-virtuoso.
>
> - packages/ui/src/DataTable/* (component + types + tests)
> - Storybook: components-ui-data-table--all-variants
> - API mirrors <Table> so call sites swap with one rename
>
> Closes: ACM-1234
> Storybook: components-ui-data-table--all-variants
> ```
>
> Why this works: scope = `packages/<package-name>` (monorepo convention), summary names the concrete component and ticket, body explains the WHY (OOM at 10k rows), trailers cross-link the ticket and the Storybook story.
>
> Replace this section with **2-3 of your own real commits** with annotations explaining what makes them work in your team's context.

---

## 7. Anti-Patterns Specific to This Project

In addition to universal §11 anti-patterns:

{{PROJECT_ANTI_PATTERNS}}

> Example entries — replace with patterns your team has actually had to call out:
> - **Translating brand or regulatory names** (e.g., `BoardKit → "board kit"`) — loses precision and breaks `git log --grep`
> - **PR titles without `type(scope):`** — bot rejects at merge time but wastes a review cycle; title PRs from the start
> - **Squashing without rewriting the PR body** — the auto-generated WIP-commit list is not a commit body (see universal `examples/good-commits.md` §L.7)
> - **Skipping `Refs:` trailer** — your ticket system sees no commit reference even though work was clearly done
> - **Bundling phase commits** (e.g., `plan + design + module-1 + module-2` in one commit) — defeats `git bisect` and your project's phase-auto-commit policy
> - **Putting feature-flag names in summary instead of `Flag:` trailer** — flags pollute `git log --oneline`

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | {{DATE}} | Initial dialect scaffolded by `principled-git-commit@{{SKILL_VERSION}}` | scaffold |
