# Multi-Agent Coordination Guide

> 멀티 에이전트 병렬 실행으로 작업 효율 극대화

---

## 핵심 원칙

| 원칙           | 방법                                  | 효과               |
| -------------- | ------------------------------------- | ------------------ |
| **TEAM FIRST** | 복잡한 병렬 작업은 Agent Teams 우선   | 협업 + 수명주기    |
| **PARALLEL**   | 독립 작업은 단일 메시지에서 동시 호출 | 5-10배 속도 향상   |
| **BACKGROUND** | 긴 작업은 백그라운드로 실행           | 메인 컨텍스트 보호 |
| **DELEGATE**   | 전문 에이전트에 즉시 위임             | 품질 향상          |

```typescript
// ✅ 병렬 실행 — 단일 메시지에서 동시 호출
Task(subagent_type="explore", model="haiku", prompt="파일 구조 분석");
Task(subagent_type="explore", model="haiku", prompt="API 패턴 분석");
```

---

## Agent Teams vs Task 선택 기준

> Agent Teams는 Claude Code Max 플랜 전용. 미가용 시 Task 병렬 호출로 폴백.

| 조건                      | 실행 방식                     |
| ------------------------- | ----------------------------- |
| 3개+ 에이전트 병렬 협업   | **Agent Teams** (TeamCreate)  |
| 에이전트 간 통신 필요     | **Agent Teams** (SendMessage) |
| 2개 이하 독립 작업        | Task 병렬 호출 (팀 불필요)    |
| Agent Teams 미가용 (플랜) | Task 병렬 호출 (폴백)         |

---

## 대규모 작업: Dynamic Workflows · ultracode (opt-in)

| 옵션 | 무엇 | 언제 |
| ---- | ---- | ---- |
| **Dynamic Workflows** | Claude가 JS 스크립트로 서브에이전트를 대규모 오케스트레이션(공식 research preview). 백그라운드 실행, 중간 결과는 스크립트 변수에 보관해 컨텍스트 절약. `/workflows`로 관리·저장 | 수십~수백 서브에이전트가 필요한 탐색·감사·마이그레이션 |
| **ultracode** | `/effort ultracode` — `xhigh` 추론 + Dynamic Workflow 자동 오케스트레이션 권한(세션 전용) | HIGH 복잡도 **+ 대규모** 작업(도메인 리팩토링, 전면 감사) |

> **기본값 아님**: ultracode는 작업당 여러 워크플로우를 띄워 토큰 소비가 크다. 진짜 대규모 작업에만 opt-in한다.
> **용어 구별** — `effort`: 추론 깊이 레벨(low~max). `ultracode`: Claude Code 세션 설정(xhigh + 자동 워크플로우). `ultrathink`: 일회성 깊은 추론 프롬프트 키워드(API effort는 바꾸지 않음).
> 아래 Task 병렬 패턴은 이 Dynamic Workflows의 turn-by-turn(컨텍스트 보유) 버전이다.

---

## 에이전트 타입 선택 기준

구현이 필요한 서브에이전트는 **항상 `general-purpose`로 spawn**한다.
역할별 전문 지식은 **프롬프트에서 스킬/규칙 파일 읽기를 지시**하여 주입한다.

| 작업 유형          | 에이전트 타입       | 이유                       |
| ------------------ | ------------------- | -------------------------- |
| 읽기 전용 탐색     | `explore`           | 빠르고 가볍다              |
| 린트/타입 수정만   | `lint-fixer`        | 규칙 기반 단순 수정        |
| 구현이 필요한 작업 | **general-purpose** | Write/Edit/Bash 필요       |
| 스킬 지식 필요     | **general-purpose** | 스킬 파일 읽기 + 구현 동시 |

### 역할별 필수 참조 파일

| 역할      | 스킬 파일                          | 규칙 파일                                           |
| --------- | ---------------------------------- | --------------------------------------------------- |
| UI 구현   | -                                  | `.claude/rules/core/react-conventions.md`           |
| API 연동  | -                                  | `.claude/rules/core/state-and-server-state.md`      |
| 리팩토링  | `.claude/skills/refactor/SKILL.md` | `.claude/rules/core/unit-test-conventions.md`       |
| 버그 수정 | `.claude/skills/bug-fix/SKILL.md`  | -                                                   |

---

## 모델·effort 선택 기준

모델은 **능력**을, effort는 그 능력 안에서 **추론 깊이·비용**을 결정한다(두 축은 직교). 별칭은 항상 최신 세대를 자동 추적한다 — 현재 `haiku`=Haiku 4.5, `sonnet`=Sonnet 4.6, `opus`=Opus 4.8(adaptive thinking, 고정 thinking budget 없음). 그래서 풀ID로 핀하지 않는다.

| 복잡도     | 모델   | effort               | 사용 케이스                                        |
| ---------- | ------ | -------------------- | -------------------------------------------------- |
| **LOW**    | haiku  | `low`                | 파일 탐색, 단순 검색, 린트 수정, 커밋/브랜치 관리  |
| **MEDIUM** | sonnet | `medium`             | 코드 리뷰, 테스트 생성, 구현 (기본값)              |
| **HIGH**   | opus   | `high` (대규모 `xhigh`) | 아키텍처 설계, 복잡한 버그, 리팩토링 분석        |

**비즈니스 로직이 포함되면 모델·effort를 함께 상향:**

| 작업 성격                             | 최소 모델  | effort     |
| ------------------------------------- | ---------- | ---------- |
| 날짜/금액/수량 계산, 상태 전이        | **opus**   | `high`     |
| 조건부 렌더링, disabled/readonly 조건 | **sonnet** | `medium`   |
| 필터/정렬/검색 로직                   | **sonnet** | `medium`   |
| 아키텍처 변경, 모듈 간 의존성 재설계  | **opus**   | `xhigh`    |

> 불확실하면 **sonnet / `medium`** — haiku 미달보다 sonnet 과잉이 안전하다.
> effort는 `/effort <레벨>`, `--effort` 플래그, 또는 에이전트 frontmatter `effort`로 설정한다. `xhigh`는 Opus 4.7/4.8 전용, `max`는 세션 전용.

---

## Agent Teams 워크플로우

```
1. TeamCreate({ team_name: 'sprint-team', description: '...' })
2. Task(subagent_type='general-purpose', team_name='sprint-team', name='ui-implementor', model='sonnet', prompt=`...`)
   Task(subagent_type='general-purpose', team_name='sprint-team', name='api-integrator', model='sonnet', prompt=`...`)
3. 팀원: 스킬/규칙 읽기 → 구현 → done-process.md 수행 → SendMessage 보고
4. 팀 리드: 결과 취합 → 충돌 해결 → 통합 린트/빌드 검증
5. release-gate 기준 PASS 확인
6. evaluation.md 기준 팀원 평가 → shutdown_request → TeamDelete
```

### 팀 리드 완료 체크리스트

```
□ 1. 각 팀원의 done-process.md done 프로세스 수행 확인
     - 미수행 시 SendMessage로 재요청 (shutdown 전에 반드시 완료)
□ 2. git log로 각 팀원 커밋 존재 확인
□ 3. {패키지매니저} lint/build 통합 검증
□ 4. release-gate 기준 최종 PASS 확인
□ 5. evaluation.md 기준 팀원 평가 작성 → 사용자 공유
□ 6. shutdown_request → TeamDelete
```

> shutdown/TeamDelete를 먼저 실행하면 팀원 컨텍스트가 소실되어 보완 불가.

---

## 에러 핸들링

실패 감지 시 **3회 루프를 먼저 실행하고, 소진 전까지 사람에게 보고하지 않는다.**

| 유형              | 판단 기준                    | 대응                      |
| ----------------- | ---------------------------- | ------------------------- |
| SCOPE_TOO_LARGE   | 컨텍스트 초과, 타임아웃      | 작업 분할 후 재시도       |
| ENV_ERROR         | 경로 오류, 파일 없음         | 경로/환경 재확인 후 재시도|
| LOGIC_ERROR       | 타입 에러, 빌드/테스트 실패  | 다른 접근법으로 재시도    |

- **2회차**: effort 상향(`low→high`)을 먼저 시도하고, 그래도 실패하면 세대 승급(`haiku→sonnet→opus`) 후 재시도 — 비용 효율 순서
- **3회차**: 루프 종료 → 사람에게 보고 (실패 유형, 시도 방법, 에러 메시지)
- **병렬 부분 실패**: 성공 결과만 활용 + 실패 작업 재시도. 전체 실패 시 순차 실행으로 전환.

---

## 참조 문서

| 문서               | 경로                                  |
| ------------------ | ------------------------------------- |
| 에이전트 목록      | `./roster.md`                         |
| 팀원 Done 프로세스 | `./done-process.md`                   |
| 팀 평가 템플릿     | `./evaluation.md`                     |
| 금지 패턴          | `../quality-gates/anti-patterns.md`   |
