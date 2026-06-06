---
paths:
  - "**/*.{test,spec}.{ts,tsx}"
  - "**/__tests__/**/*.{ts,tsx}"
---

# 순수 함수 유닛 테스트 규칙

순수 함수(utils, helpers, lib, adapters)에 대한 유닛 테스트 작성 규칙입니다.

---

## 테스트 러너 감지

| 설정 파일 | 러너 | 타이머 API |
|-----------|------|-----------|
| `vitest.config.*` 존재 | vitest | `vi.useFakeTimers()` / `vi.useRealTimers()` |
| `jest.config.*` 존재 | jest | `jest.useFakeTimers()` / `jest.useRealTimers()` |

> 아래 예시는 jest 기준이며, vitest 프로젝트에서는 `jest` → `vi`로 치환합니다.

---

## 적용 대상

- `utils/`, `helpers/`, `lib/`, `adapters/` 내 순수 함수
- 날짜 계산, 포맷팅, 상태 변환, 데이터 매핑 등

---

## 파일 위치

```
{파일경로}/__tests__/{파일명}.test.ts
```

**예시:**

- `utils/date.ts` → `utils/__tests__/date.test.ts`
- `adapters/mapUser.ts` → `adapters/__tests__/mapUser.test.ts`

---

## 테스트 구조 (필수 준수)

```typescript
import { 함수명 } from '../파일명';

describe('함수명', () => {
  // 날짜/시간 의존 함수만 아래 타이머 고정 추가 (불필요하면 생략)
  beforeAll(() => {
    jest.useFakeTimers().setSystemTime(new Date('2024-01-15T00:00:00.000Z'));
  });
  afterAll(() => jest.useRealTimers());

  describe('정상 케이스', () => {
    it('일반적인 입력에 대해 올바른 결과 반환', () => {
      expect(함수(입력)).toEqual(기대값);
    });
  });

  describe('경계값', () => {
    it('최소값 처리', () => {});
    it('최대값 처리', () => {});
    it('빈 값 처리', () => {});
  });

  describe('에러 케이스', () => {
    it('잘못된 입력 시 에러/기본값 반환', () => {});
  });
});
```

---

## 테스트 케이스 도출 (필수)

모든 순수 함수는 아래 카테고리를 커버해야 합니다:

| 카테고리    | 설명                        | 예시                            |
| ----------- | --------------------------- | ------------------------------- |
| 정상 케이스 | 일반적인 유효 입력          | `formatDate(new Date())`        |
| 경계값      | 0, 빈 배열, null, undefined | `formatDate(null)`              |
| 에러 케이스 | 잘못된 타입, 범위 초과      | `formatDate('not-a-date')`      |
| 정책 케이스 | 비즈니스 규칙 반영          | `특정 포맷 규칙 준수 여부`      |

---

## 함수 유형별 필수 케이스

아래는 **날짜 함수** 대표 예시입니다. 계산·매핑 함수도 동일한 구조(정상 → 경계값 → 에러)를 따르며, 차이점만 아래에 정리합니다.

```typescript
describe('formatDate', () => {
  // 날짜 함수는 반드시 타이머 고정
  beforeAll(() => {
    jest.useFakeTimers().setSystemTime(new Date('2024-01-15T00:00:00.000Z'));
  });
  afterAll(() => jest.useRealTimers());

  it('유효한 날짜를 지정 포맷으로 반환', () => {
    expect(formatDate(new Date('2024-01-15'))).toBe('2024-01-15');
  });

  it('null 입력 시 빈 문자열 반환', () => {
    expect(formatDate(null)).toBe('');
  });

  it('잘못된 문자열 입력 시 기본값 반환', () => {
    expect(formatDate('invalid')).toBe('');
  });
});
```

- **날짜 함수**: `jest.useFakeTimers()`로 시간 고정 필수. 정상 포맷 / `null` / 잘못된 문자열을 커버.
- **계산 함수** (`clamp` 등): 범위 내 그대로 반환 / 최솟값 미만 → 최솟값 / 최댓값 초과 → 최댓값 / 소수점 처리를 커버. 타이머 불필요.
  ```typescript
  expect(clamp(5, 0, 10)).toBe(5);
  expect(clamp(-1, 0, 10)).toBe(0);
  expect(clamp(11, 0, 10)).toBe(10);
  ```
- **매핑/변환 함수** (`mapUserToDto` 등): 모든 필드 존재 시 정상 변환 / optional 필드 누락 시 기본값 / `null` 입력 시 기본 DTO 반환을 커버. 타이머 불필요.
  ```typescript
  expect(mapUserToDto({ id: '1', name: 'Alice', age: 30 }))
    .toEqual({ userId: '1', displayName: 'Alice' });
  expect(mapUserToDto(null)).toEqual(DEFAULT_USER_DTO);
  ```

---

## 네이밍 컨벤션

```typescript
// describe: 함수명 또는 모듈명
describe('formatDate', () => {
  // 중첩 describe: 시나리오 그룹
  describe('정상 케이스', () => {
    // it: 구체적인 동작 설명 (한글 권장)
    it('유효한 날짜를 YYYY-MM-DD 형식으로 반환', () => {});
  });
});
```

---

## 금지 사항

- **구현 상세 의존 금지**: 내부 함수 spy, private 메서드 접근
- **외부 의존성 실제 호출 금지**: API, DB, 파일 시스템
- **테스트 간 상태 공유 금지**: 전역 변수로 테스트 연결
- **하드코딩된 날짜 금지**: `jest.useFakeTimers()` 사용

---

## 테스트 실행

```bash
# 패키지 매니저 자동 판단 (yarn.lock → yarn, package-lock.json → npm, pnpm-lock.yaml → pnpm)

# 단일 파일
{패키지매니저} test -- --testPathPattern="date.test.ts"

# 전체
{패키지매니저} test
```

---

## 정책 보호 테스트

리팩토링 시 기존 동작을 보호하는 테스트입니다:

```typescript
// 현재 동작을 "캡처"
describe('formatDate 정책 (회귀 방지)', () => {
  // 이 테스트가 깨지면 = 정책이 바뀐 것
  // 의도된 변경인지 확인 필요
});
```

---

## 체크리스트

테스트 작성 전 확인:

- [ ] 정상 케이스 포함?
- [ ] 경계값 (0, 빈 값, null) 포함?
- [ ] 에러 케이스 포함?
- [ ] 날짜 함수면 `jest.useFakeTimers()` 사용?
- [ ] 정책 관련 함수면 정책 케이스 포함?
