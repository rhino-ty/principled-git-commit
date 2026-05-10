# TTiRingGo — Commit Dialect (Example)

> Example dialect file showing what a real project's `docs/references/COMMIT.md` looks like. This is the **TTiRingGo case** — a Korean SaaS messaging platform with PDCA-driven development. Use as a reference when filling out your own dialect.

---

## 1. Domain Proper Nouns

| Term | English equivalent (do NOT use in commits) | Why kept |
|---|---|---|
| 친구톡 | "KakaoTalk friend message" | regulatory channel name |
| 알림톡 | "KakaoTalk notification" | regulatory channel name |
| 발신번호 | "sender number" | regulatory term used in MOC, KCC docs |
| 수신거부 | "opt-out" | 정통망법 §50 explicit terminology |
| 광고문자 | "ad text message" | regulatory category |
| 야간 | "night-time" | 정통망법 §50③ blocked window terminology |
| 정통망법 | (do not translate) | statute name |
| 포인트 | "point" | product-internal currency |
| 예약 발송 | "scheduled send" | feature name |

---

## 2. Scope Catalog (200-commit empirical)

| Scope | Frequency | Description |
|---|:--:|---|
| `pdca` | 13 | PDCA cycle artifacts (plan / design / analysis / report) |
| `client` | 10 | Client-side (Next.js + components) generic changes |
| `points` | 10 | Point system (charge / use / refund / admin) |
| `messages` | 8 | Messaging domain |
| `claude` | 6 | CLAUDE.md updates |
| `shared` | 4 | `@ttiringgo/shared` workspace |
| `server` | 5 | NestJS server modules |
| `templates` | 5 | Template feature |

### 2.1 Sub-scopes in active use

`messages/recipients`, `messages/compose`, `messages/actions`, `messages/send`, `client/phone`, `server/dto`, `server/opt-out`, `server/messages`

### 2.2 Multi-scope examples

`docs(claude,ui)`, `docs(claude,refs)`, `style(templates,opt-out)`

### 2.3 Feature-scopes (long-running PDCA cycles)

`sender-number-mgmt`, `message-send-ux-redesign`, `phone-input-mask-unification`, `shared-byte-migration`, `shared-phone-migration`, `shared-ad-night-time-migration`, `monorepo-shared-workspace`, `badge-system-unification`, `server-phone-regex-unification`, `points-client-alignment`

---

## 3. Custom Trailers

| Token | Purpose | Example value |
|---|---|---|
| `Plan SC:` | Plan-document Success Criteria covered | `SNM-001~004` or `BYT-001~012` |
| `Design Ref:` | Design-document section pointer | `§2.1, §5.4, §10.4` |
| `Match Rate:` | Gap analysis match score | `98.0% (raw 89.4%, iter-1)` |

---

## 4. Workflow Integration — PDCA Phase auto-commit

This project uses PDCA cycles. Each phase boundary triggers an automatic commit (no user prompt required).

| Phase boundary | Auto-commit | Example summary |
|---|:--:|---|
| Plan document complete | ✅ | `docs(sender-number-mgmt): plan v0.3 (25 FRs / 11 ADR)` |
| Design document complete | ✅ | `docs(sender-number-mgmt): design Option C — Pragmatic` |
| Do — each module complete | ✅ | `feat(sender-number-mgmt): M1 schema + INACTIVE seed` |
| Check (gap analysis) complete | ✅ | `docs(sender-number-mgmt): gap analysis 97.4%` |
| iter-N complete | ✅ | `fix(sender-number-mgmt): iter-1 SUSPENDED period display (Gap #1)` |
| Report complete | ✅ | `docs(pdca): sender-number-mgmt completion report (Match 98%)` |

User-triggered (still): `git push`, force push, branch deletion, interactive rebase.

### 4.1 Module tag

Multi-module cycles add `(Module N)` to summary or body:

```
refactor(client): adopt PhoneInput wrapper in 5 RHF phone forms (Module 5b)
fix(phone-mask): wire search hooks, ad-body byte trim, server validate (Module 6)
```

---

## 5. Type Usage Policy

**Active types**: `feat`, `fix`, `refactor`, `docs`, `style`, `chore`, `test`, `revert`

**Inactive types**:
- `perf` — no benchmark suite, performance-only commits would be `refactor` or `fix` instead
- `ci` — no GitHub Actions yet (manual deploy)
- `build` — bundled into `chore`

---

## 6. Project-Specific Examples

### 6.1 Module commit (good)

```
feat(sender-number-mgmt): M1 schema + INACTIVE seed

PDCA Phase=Do. ★ invariant via partial UNIQUE; INACTIVE via 공통코드.

- server/src/db/schema/sender-numbers.schema.ts: +alias varchar(30),
  +isDefault boolean, +partial UNIQUE `WHERE is_default = true`
- database/init/insert_common_codes.sql: +SENDER_STATUS / 'INACTIVE'
  (sort 25, between APPROVED 20 and REJECTED 30)
- server/drizzle/0002_sender-number-mgmt.sql: drizzle-kit up + manual
  data migration (ROW_NUMBER seed for existing APPROVED rows)
- server/drizzle/down/0002_*.down.sql: manual down (drizzle 자동 down 미지원)

Verification: migration applied, 3 users have exactly 1 ★, partial
UNIQUE 0 violations, INACTIVE seed present.

Plan SC: SNM-001~004
```

Why this works: scope = feature name; `PDCA Phase=Do` makes workflow grep-able; bullets are concept-level not file enumeration; `Plan SC` trailer cross-links the plan; 발신번호/공통코드/INACTIVE proper nouns kept.

### 6.2 PDCA wrap commit (good)

```
docs(pdca): completion report for shared-byte-migration (Match Rate 100%)

- docs/04-report/features/shared-byte-migration.report.md (final 100% static)
- 12 export 합의: 4 const + 8 pure fn (1 query GROUP BY + EUC-KR + carrier limits)
- server/client 양방향 inline 잔재 0건 (grep audit 통과)
```

### 6.3 Cautionary tale (bad — pre-policy)

```
b8792c0  feat(sender-number-mgmt): plan/design + M1 schema + M2 server API
```

84-line body bundling Plan + Design + M1 + M2 (4 phases). Violates universal §0.1 atomic + this dialect's §4 phase-auto-commit policy. The git log can't show PDCA flow because the entire cycle's first half is one commit. **Do not repeat.** This dialect was added partly in response to this commit.

---

## 7. Project-Specific Anti-Patterns

In addition to universal §11:

- **Translating Korean proper nouns** (e.g., `친구톡 → "friendtalk"`) — breaks regulatory specificity and grep-ability
- **Bundling PDCA phases** (Plan + Design in one commit) — violates §4 phase boundary
- **Skipping `Plan SC` trailer** on PDCA module commits — breaks plan-to-code traceability
- **Using English `sender number` instead of `발신번호`** in commit body — loses precision

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.4 | 2026-05-10 | Latest version of this dialect — see TTiRingGo `docs/references/COMMIT.md` for the live file |
| 0.1 | 2026-05-10 | Initial dialect derived from 200-commit empirical study |
