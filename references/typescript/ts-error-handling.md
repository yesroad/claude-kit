# TypeScript 에러 처리 패턴

## 1. Result 타입 패턴 — try/catch 탈출

### 1.1 직접 구현

```typescript
type Ok<T> = { success: true; data: T };
type Err<E> = { success: false; error: E };
type Result<T, E = Error> = Ok<T> | Err<E>;

const ok = <T>(data: T): Ok<T> => ({ success: true, data });
const err = <E>(error: E): Err<E> => ({ success: false, error });

async function fetchUser(id: string): Promise<Result<User, 'NOT_FOUND' | 'NETWORK_ERROR'>> {
  try {
    const res = await fetch(`/api/users/${id}`);
    if (res.status === 404) return err('NOT_FOUND');
    return ok(await res.json());
  } catch {
    return err('NETWORK_ERROR');
  }
}

// 호출 측: 에러를 반드시 처리해야 함 (타입이 강제)
const result = await fetchUser("123");
if (!result.success) {
  if (result.error === 'NOT_FOUND') showNotFoundPage();
  return;
}
console.log(result.data.name); // result.data 타입: User
```

### 1.2 neverthrow 라이브러리 (현업 표준)

```bash
npm install neverthrow
```

```typescript
import { ok, err, ResultAsync } from 'neverthrow';

function findUser(id: UserId): ResultAsync<User, DbError> {
  return ResultAsync.fromPromise(
    db.users.findById(id),
    (e) => new DbError('USER_NOT_FOUND', e)
  );
}

// 체이닝으로 여러 단계 처리
const result = await findUser(userId)
  .andThen(user => sendWelcomeEmail(user.email))
  .mapErr(err => logError(err));

result.match(
  (data) => console.log('성공:', data),
  (error) => console.error('실패:', error.message)
);
```

---

## 2. 에러를 타입으로 구분

```typescript
type AppError =
  | { type: 'VALIDATION'; fields: Record<string, string> }
  | { type: 'NOT_FOUND'; resource: string }
  | { type: 'UNAUTHORIZED' }
  | { type: 'NETWORK'; statusCode: number }
  | { type: 'UNKNOWN'; message: string };

// switch가 exhaustive — 케이스 빠뜨리면 컴파일 에러
function handleError(error: AppError) {
  switch (error.type) {
    case 'VALIDATION':    return showFieldErrors(error.fields);
    case 'NOT_FOUND':     return showNotFound(error.resource);
    case 'UNAUTHORIZED':  return redirectToLogin();
    case 'NETWORK':       return showNetworkError(error.statusCode);
    case 'UNKNOWN':       return showGenericError(error.message);
  }
}
```

---

## 3. never를 이용한 exhaustive 체크

```typescript
function assertNever(value: never): never {
  throw new Error(`처리되지 않은 케이스: ${JSON.stringify(value)}`);
}

function processStatus(status: 'pending' | 'active' | 'closed') {
  switch (status) {
    case 'pending': return handlePending();
    case 'active':  return handleActive();
    case 'closed':  return handleClosed();
    default:        return assertNever(status);
    // 'cancelled' 등 케이스 추가 시 → 컴파일 에러로 누락 방지
  }
}
```
