---
name: principled-git-commit
description: >
  Conventional Commits 1.0.0 + 베스트 프랙티스 워크플로 (diff → staging →
  type 결정 → secrets blocklist → 사전 체크리스트) + 5 founding principle
  (atomic / leaves-repo-green / why-over-what / imperative / searchable) +
  project dialect scaffolding. 커밋을 4 reader (`git log` 스캐너 / `git blame`
  추적자 / `git bisect` 사냥꾼 / AI agent — `/clear` 컨텍스트 복원 / PR 리뷰 /
  changelog 생성 / NL 질의)에게 동시에 도움되는 영구 history로 다룸.

  본 파일은 한국어 prose 변형. 룰 자체 (영문 default body, lowercase summary,
  imperative mood, atomic / why-over-what 등 §0 전 원칙)는 영문 SKILL.md와
  동일 — 변형 무관.

  ALWAYS trigger 조건은 영문 SKILL.md frontmatter §ALWAYS와 동일.

  Triggers (multi-lingual):
  EN: commit, git commit, stage, commit message, breaking change,
      conventional commits, revert, fixup, amend, cherry-pick, changelog
  KO: 커밋, 깃 커밋, 스테이지, 커밋 메시지, 커밋 룰, 컨벤셔널 커밋, 리버트,
      되돌리기, 어맨드, 커밋 컨벤션, 커밋 메시지 검토
  JA: コミット, git コミット, ステージ, コミットメッセージ, ブレーキング
      チェンジ, リバート, アメンド
  ZH: 提交, git 提交, 暂存, 提交信息, 提交消息, 重大变更, 回滚, 修订

  Audience: 한국어를 모국어로 쓰는 개발자. §0 founding principle을 한국어로
  먼저 잡고 싶은 사용자에게 적합. §1-§14 룰 자체는 영문 SKILL.md를 정본으로
  참조 — 본 변형이 룰을 새로 정의하지 않음.
license: MIT
metadata:
  author: rhino-ty
  version: "0.1.3"
  variant: ko
---

# Commit Conventions (Korean prose variant)

> Conventional Commits 1.0.0 + Tim Pope + `awesome-copilot/git-commit` + 200-commit 실측 분석을 통합한 보편 commit 컨벤션. 프로젝트 특화 dialect (도메인 고유명사, 커스텀 trailer, PDCA 같은 워크플로 통합)는 `<project>/docs/references/COMMIT.md`에 — §15 Dialect Loading 참조.
>
> **TL;DR**: `type(scope): summary` (≤100자, lowercase, imperative) + 1-2줄 컨텍스트 + `- ` bullet body (평균 16줄). `##` 헤더 X. body는 영문 default. atomic + leaves-repo-green + why-over-what.

---

## 0. Principles

Commit이 만족시켜야 할 4 reader — **사람 + AI 모두**:

1. **`git log --oneline` 스캐너** — summary 한 줄로 컨텍스트 잡으려는 사람 (가장 많음)
2. **`git blame <file>` 추적자** — "왜 이 줄이 여기 있나" 디버깅 중
3. **`git bisect` 사냥꾼** — production fire 중, 깨진 commit 찾는 사람
4. **AI agent** — `/clear` 후 컨텍스트 복원, PR 리뷰, changelog 생성, NL 질의 → 코드 위치 매핑. **`grep` + 임베딩 검색 + 일관된 구조에 의존**. atomic 단위 + 도메인 keyword + 영문 body + 명시 trailer가 결정적

5개 principle은 이 4 reader를 동시에 만족시키는 최소 룰. 의문 생기면 회귀.

### 0.1 Atomic — 한 commit = 한 의도

하나의 논리적 변경만 담는다. "fix + style + docs" 같이 묶지 말 것.

→ **Bisect / revert / cherry-pick 모두 atomic 전제**. AI도 mixed commit은 한쪽만 잡아 hallucinate.

> 판단: "이 commit을 revert해야 할 때 다른 변경까지 같이 revert하는가?" → YES면 split.

### 0.2 Leaves repo green — 모든 commit은 green build

각 commit 직후 `tsc --noEmit` + `lint` + `build` 통과해야 함. WIP / "next commit will fix this" 금지.

→ **Bisect signal 신뢰성**. broken-state commit이 끼면 "원인" 판정 부정확. AI 자동 분석도 같은 이유로 영향.

### 0.3 Why over what — diff가 못 알려주는 것만 본문에

diff는 WHAT을 보여줌. body는 **WHY** (motivation / trade-off / 어떤 대안 버렸나) 중심.

→ **6개월 후 blame 질답에 직답**. AI는 diff context 없이도 commit body에서 의도 추출 가능 (diff 추론 비용 + 오해 위험).

```
❌ Body: "modify foo.ts to add bar method"        (diff 중복)
✅ Body: "extract bar() out of inline closure —    (WHY)
        prevents re-allocation on every render
        causing useMemo deps invalidation"
```

### 0.4 Imperative mood — "If applied, this commit will..."

Summary는 명령형. git 자체 메시지(`Merge`, `Revert`)와 통일.

→ **일관된 verb 패턴**. git tooling + AI classification (changelog 생성, type 추정) 모두 동사 형태에 의존.

```
✅ add idempotency-key support to /v1/payments
✅ fix double-render in <Modal> on focus return
✅ migrate auth hashing from bcrypt to argon2id
❌ added idempotency-key support     (과거형)
❌ adding idempotency-key support    (진행형)
❌ idempotency-key support added     (수동태)
```

### 0.5 Searchable — keyword-rich summary + body

도메인 명사 / 함수명 / 파일 경로 / SoT 이름 / 컴포넌트 이름을 명시. vague 동사(`improve`, `update`, `enhance`)는 대상 명사로 보강.

→ **`git log --grep` + AI 임베딩 검색**. 6개월 후 "Idempotency-Key 어디서 추가했지?" 같은 자연어 질의가 1번에 정답 commit으로 hit. AI는 vague keyword에 hallucinate, 구체 keyword에 정확.

```
❌ feat(api): improve checkout
✅ feat(api/payments): add Idempotency-Key header support with 24h replay window

❌ refactor: cleanup auth helpers
✅ refactor(auth): replace bcrypt with argon2id (memory-hard against GPU attackers)
```

---

## 영문 SKILL.md와의 관계

§1-§14 모든 룰은 영문 SKILL.md와 **동일**. 본 ko 변형은 prose 설명만 한국어. 룰 자체 (lowercase summary, imperative, English body 정책 등)는 변형 무관.

§1 Format / §2 Types / §3 Scopes / §4 Body Length / §5 Markdown / §6 Breaking Changes / §7 Workflow / §8 Trailers / §9 Amend/Fixup / §10 Reverts / §11 Anti-patterns / §12 Quick Reference / §13 Project Dialect / §14 Source Attribution — 영문 SKILL.md 참조.

본 변형은 **§0 principle 본문만 한국어로 작성**해 한국어 사용자가 founding rule 의도를 한 번에 이해하도록 함. 나머지는 매 trigger마다 한국어로 옮길 가치보다 영문 정합성이 더 큼 — git tooling, AI 모델, 외부 contributor 모두 영문 기대.

## 작성 시 마음가짐 — 4가지 압축

1. **Audience first**: "6개월 후 내가 이 줄에 `git blame` 찍었을 때 답이 나오나?"
2. **Atomic test**: "revert할 때 다른 변경까지 끌고 가나?" → YES면 split
3. **Why over What**: diff가 보여주는 것 다시 쓰지 말 것
4. **Searchable**: vague 동사 금지. 도메인 명사 / 함수명 / 컴포넌트 이름 적기

이게 §0의 본질. 룰 14개 모두 이 4가지의 구현 디테일.
