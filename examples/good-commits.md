# Annotated Good Commits

Real commits from the TTiRingGo project that follow the universal conventions plus the project's PDCA dialect. Use as reference when writing your own.

---

## 1. Single-concept fix (no body needed)

```
fix(messages): add cursor-pointer to native button elements
```

**Why this works**:
- Summary alone says everything — the diff is small enough that a body would just restate it (§0.3 violation if added)
- Type `fix` is correct (regression — buttons used to show pointer, lost it during a refactor)
- Scope `messages` is the actual domain
- Imperative `add` (§0.4)
- Concrete noun `cursor-pointer` (§0.5)

---

## 2. Single-concept fix with focused body

```
fix(client): improve phone mockup contrast and sender select default fallback

- preview/channel-frame-sms.tsx: phone mockup outer bg `bg-background` -> `bg-card`
  light: Slate 50 (matched page bg) -> #ffffff (clear contrast)
  dark: Slate 950 -> Slate 900 (slightly brighter card tone)
- sender-number-select.tsx: replace `getValues('senderNumberId')` with
  `useWatch` + boolean dep narrow so default re-applies after `form.reset()`
  in send page (effect deps now react to form value changes; previously
  reset left the field blank because deps were stable)
```

**Why this works**:
- Two related fixes — one visual (contrast) one logical (default fallback) — both small enough to bundle without violating atomic
- Body explains the WHY for the second fix ("effect deps now react... previously reset left the field blank") — not derivable from diff alone
- Concrete file paths + concrete tokens (`bg-background`, `bg-card`, `useWatch`) — fully searchable
- 8 lines body for a 2-file fix — within sweet spot

---

## 3. Module-scale refactor (PDCA Phase commit)

```
feat(sender-number-mgmt): M1 schema + INACTIVE seed

PDCA Phase=Do. ★ invariant via partial UNIQUE; INACTIVE via 공통코드.

- server/src/db/schema/sender-numbers.schema.ts: +alias varchar(30),
  +isDefault boolean, +partial UNIQUE `WHERE is_default = true`
- database/init/insert_common_codes.sql: +SENDER_STATUS / 'INACTIVE'
  (sort 25, between APPROVED 20 and REJECTED 30)
- server/drizzle/0002_sender-number-mgmt.sql: drizzle-kit up + manual
  data migration (ROW_NUMBER seed for existing APPROVED rows)
- server/drizzle/down/0002_*.down.sql: manual down (drizzle has no auto down)

Verification: migration applied, 3 users have exactly 1 ★, partial
UNIQUE 0 violations, INACTIVE seed present.

Plan SC: SNM-001~004
```

**Why this works**:
- Scope = feature name (long-running PDCA cycle)
- `PDCA Phase=Do` makes workflow context grep-able
- Bullets are concept-level (`+alias varchar(30)`), not raw file paths
- Korean proper nouns kept: `공통코드` (general-code, regulatory term)
- `Verification:` block confirms green build
- `Plan SC: SNM-001~004` trailer cross-links to Plan document

This is dialect-aware — the trailer + `Phase=Do` come from the project's `docs/references/COMMIT.md` extension.

---

## 4. PDCA wrap commit

```
docs(pdca): completion report for shared-byte-migration (Match Rate 100%)

- docs/04-report/features/shared-byte-migration.report.md (final 100% static)
- 12 export agreement: 4 const + 8 pure fn (1 query GROUP BY + EUC-KR + carrier limits)
- server/client both inline residue 0 hits (grep audit passed)
```

**Why this works**:
- Scope `pdca` signals "this is a cycle deliverable, not a code change"
- Match rate in summary makes it scannable from `git log --oneline`
- Body confirms what the cycle achieved (100% match, 0 residue) without restating the diff

---

## 5. Breaking change

```
refactor(shared)!: migrate byte SoT to @ttiringgo/shared/byte

- 12 export defined: 4 constants + 8 pure fns
- server/client both inline byte calc removed (grep 0 hits)
- DTO byte validator class-validator decorator unified

BREAKING CHANGE: client/lib/utils/byte.ts removed. Import from
@ttiringgo/shared/byte instead. CallSites: 9 client + 12 server
already migrated; external code (none currently) must update.

Plan SC: BYT-001~012
Match Rate: 100% (static)
```

**Why this works**:
- Both `!` and `BREAKING CHANGE:` footer used (belt-and-suspenders for caller awareness)
- Body lists the migration result quantitatively (12 exports, 9+12 callsites)
- Footer specifies what callers must do
- `Plan SC` + `Match Rate` trailers cross-link to PDCA artifacts

---

## 6. Revert

```
revert: feat(messages): personalized broadcast variable parsing

This reverts commit 8a3b9c2d... .

Reason: broadcast path leaks `#{name}` placeholder when contact
metadata is missing — preview shows literal `#{name}` instead of
fallback. Single-row personalized path works fine. Re-design via
queue (cycle: personalized-broadcast-queue) before re-enabling.

Refs: 8a3b9c2
```

**Why this works**:
- Auto-generated git revert message kept as-is
- **Reason** added — without this the revert is a mystery six months later
- `Refs:` trailer back-links the original hash
- Cycle name (`personalized-broadcast-queue`) is grep-able for the future re-implementation

---

## Bad commits to learn from

### "wip" / vague

```
chore: wip
fix: bug
docs: update
```

**Why these fail**: §0.5 — `git log --grep="bug"` returns hundreds of unrelated hits. AI embedding search is useless. Six months later `git blame` lands on `fix: bug` and the developer has to read the entire diff to understand the change.

### Bundled phases

```
feat(sender-number-mgmt): plan/design + M1 schema + M2 server API
```

(84-line body bundling Plan + Design + 2 implementation modules.)

**Why this fails**: Violates §0.1 atomic + the project's dialect §4 PDCA Phase auto-commit. The git log shows one commit where there should be four — bisect can't isolate which phase introduced a regression. Lesson: write the dialect's §4 policy *before* the cycle, not after.

### Markdown headers in body

```
feat(foo): rewrite bar

## Background
[long paragraph]

## Implementation
[long paragraph]

## Testing
[long paragraph]
```

**Why this fails**: §5 — `## Background` renders as literal `## Background` in `git log`, becoming visual noise. Replace with plain `Background:` labels. (5/200 outlier in our corpus.)

### Past tense

```
feat: added phone validator
fix: fixed double-render
```

**Why these fail**: §0.4 — past tense breaks the "If applied, this commit will..." convention git itself uses. Auto-changelog tools and AI summarizers expect imperative.

### `git add -A` style commit

```
chore: misc updates
```

(Diff includes 47 files across 12 unrelated domains.)

**Why this fails**: Violates §0.1 atomic and §7.2 explicit-path staging. Often inadvertently includes secrets (`.env`) or unrelated WIP. Bisect, revert, and review are all crippled.
