# Instructions Index

> Claude Code 작업 효율화를 위한 가이드 모음

---

## 문서 구조

```
.claude/instructions/
├── README.md                         # 이 파일
├── multi-agent/
│   ├── coordination-guide.md         # 병렬 실행 + 실행 패턴 + 에러 복구 (SSOT)
│   ├── agent-roster.md               # 에이전트 카탈로그 + 스킬 카탈로그
│   ├── team-evaluation.md            # Agent Teams 평가 기준 (Max 플랜 전용)
│   └── teammate-done-process.md      # 팀원 완료 프로세스
├── validation/
│   ├── forbidden-patterns.md         # 금지 패턴 목록
│   ├── required-behaviors.md         # 필수 행동 규칙
│   └── release-readiness-gate.md     # 출시 품질 게이트
├── workflow-patterns/
│   └── thinking-model.md             # 통합 사고 모델 + 복잡도 판단 (SSOT)
└── git/
    └── pr-guide.md                   # PR 작성 가이드
```

---

## 문서 카탈로그

### Multi-Agent

| 문서                       | 용도                                      | 사용 시점                |
| -------------------------- | ----------------------------------------- | ------------------------ |
| `coordination-guide.md`    | 병렬 실행, 실행 패턴, 에러 복구, 모델 라우팅 | 에이전트 조합 필요 시    |
| `agent-roster.md`          | 에이전트 + 스킬 카탈로그                  | 에이전트/스킬 선택 시    |
| `team-evaluation.md`       | Agent Teams 팀원 평가 기준 (Max 플랜)     | 팀 작업 완료 후          |
| `teammate-done-process.md` | 팀원 5단계 완료 프로세스                  | 팀원 spawn 시 참조       |

### Validation

| 문서                        | 용도                                  | 사용 시점         |
| --------------------------- | ------------------------------------- | ----------------- |
| `forbidden-patterns.md`     | any 타입, 정책 임의 변경 등 금지 항목 | 코드 작성/리뷰 시 |
| `required-behaviors.md`     | 필수 행동 규칙 (병렬 읽기, 검증 등)   | 모든 작업 시      |
| `release-readiness-gate.md` | 계획/구현/보안/사용자흐름 최종 게이트 | 커밋/PR 직전      |

### Workflow Patterns

| 문서                | 용도                                                         | 사용 시점    |
| ------------------- | ------------------------------------------------------------ | ------------ |
| `thinking-model.md` | READ→REACT→ANALYZE→…6단계 사고 모델 + 복잡도 판단 (SSOT)    | 모든 작업 시 |

### Git

| 문서           | 용도                                     | 사용 시점       |
| -------------- | ---------------------------------------- | --------------- |
| `pr-guide.md`  | PR 제목·섹션 작성 기준, 변경 유형별 판단 | 커밋/PR 생성 시 |

---

## 연결된 규칙

| 문서           | 경로                                              | 연결                    |
| -------------- | ------------------------------------------------- | ----------------------- |
| 통합 사고 모델 | `instructions/workflow-patterns/thinking-model.md` | 복잡도 판단 포함 (SSOT) |
| React/Next.js  | `rules/core/react-nextjs-conventions.md`           | 코드 품질               |
| 상태 관리      | `rules/core/state-and-server-state.md`             | TanStack Query          |
| 테스트 규칙    | `rules/core/unit-test-conventions.md`              | lint-fixer 연계         |
