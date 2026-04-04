# TypeScript × React / Next.js 패턴

> React 19, Next.js 15+ 기준 — 2026년 4월

---

## 1. 컴포넌트 Props 타입 추출 — ComponentProps

외부 라이브러리 컴포넌트를 래핑할 때 필수 패턴입니다.

```typescript
import { ComponentProps } from 'react';
import { Button } from 'some-ui-library';

// 라이브러리 Button Props를 그대로 상속
type CustomButtonProps = ComponentProps<typeof Button> & {
  isLoading?: boolean;
  variant?: 'primary' | 'danger';
};

function CustomButton({ isLoading, variant, ...buttonProps }: CustomButtonProps) {
  return <Button {...buttonProps} disabled={isLoading} />;
}
```

---

## 2. ref 처리 — React 19 방식

React 19부터 `forwardRef`가 deprecated되었습니다.
`ref`를 일반 prop으로 직접 받는 방식이 표준입니다.

```typescript
import { useRef, useImperativeHandle } from 'react';

// ref로 노출할 메서드 타입 정의
interface InputHandle {
  focus: () => void;
  clear: () => void;
  getValue: () => string;
}

interface InputProps {
  placeholder?: string;
  onChange?: (value: string) => void;
  ref?: React.Ref<InputHandle>; // React 19+: ref를 일반 prop으로
}

// forwardRef 래퍼 불필요 — 함수 컴포넌트에서 직접 받음
function SmartInput({ placeholder, onChange, ref }: InputProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  useImperativeHandle(ref, () => ({
    focus: () => inputRef.current?.focus(),
    clear: () => { if (inputRef.current) inputRef.current.value = ''; },
    getValue: () => inputRef.current?.value ?? '',
  }));

  return (
    <input
      ref={inputRef}
      placeholder={placeholder}
      onChange={e => onChange?.(e.target.value)}
    />
  );
}

// 사용 측
const inputRef = useRef<InputHandle>(null);
inputRef.current?.focus(); // 타입 안전
```

> React 18 이하를 지원해야 한다면 기존 `forwardRef` 방식을 유지할 것.

---

## 3. Next.js App Router 타입 패턴

Next.js 15+에서 `params`와 `searchParams`가 Promise로 변경되었습니다.

```typescript
// app/users/[id]/page.tsx
interface PageProps {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ tab?: string }>;
}

export default async function UserPage({ params, searchParams }: PageProps) {
  const { id } = await params;
  const { tab } = await searchParams;

  const user = await fetchUser(id);
  return <UserProfile user={user} activeTab={tab} />;
}
```

Server Action 타입:

```typescript
'use server';

type ActionState = {
  success: boolean;
  message: string;
  errors?: Record<string, string[]>;
};

async function updateUser(
  prevState: ActionState,
  formData: FormData
): Promise<ActionState> {
  // ...
}
```

---

## 4. 커스텀 훅 제네릭 패턴

```typescript
function useAsync<TData, TError = Error>(
  asyncFn: () => Promise<TData>
) {
  const [state, setState] = useState<{
    status: 'idle' | 'loading' | 'success' | 'error';
    data?: TData;
    error?: TError;
  }>({ status: 'idle' });

  const execute = useCallback(async () => {
    setState({ status: 'loading' });
    try {
      const data = await asyncFn();
      setState({ status: 'success', data });
    } catch (error) {
      setState({ status: 'error', error: error as TError });
    }
  }, [asyncFn]);

  return { ...state, execute };
}

// TData가 자동 추론됨
const { data, status, execute } = useAsync(() => fetchUser(id));
// data 타입: User | undefined
```
