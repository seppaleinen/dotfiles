---
type: Frontend Reference
title: Testing
description: PWA unit, component, and integration test patterns — signals, HTTP mocking, DOM interactions.
tags: [testing, angular, jest, vitest]
---

# Testing Guidelines

Testing best practices and patterns used in the Avanza PWA.

> For Mint library testing (Playwright, Vitest, axe-core), see [beta-mint-knowledge/testing-principles](/../beta-mint-knowledge/testing-principles.md).

## Testing Philosophy

- **Test behavior, not implementation** — Focus on what the component does, not how it does it
- **Keep tests simple and readable** — Tests should serve as documentation
- **Follow the AAA pattern** — Arrange, Act, Assert
- **Test one thing per test** — Each test should verify a single behavior
- **Use meaningful test names** — Describe what is being tested and expected outcome

## Test Types

### Unit Tests

Use for pure functions, pipes, services with minimal dependencies, and simple component logic.

### Component Tests

Use for component rendering, DOM interactions, input/output bindings, and template logic.

### Integration Tests

Use for service interactions, complex component hierarchies, and feature modules.

## Testing Angular Components

### Basic Component Test Structure

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MyComponent } from './my.component';

describe('MyComponent', () => {
  let component: MyComponent;
  let fixture: ComponentFixture<MyComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MyComponent],
    }).compileComponents();

    fixture = TestBed.createComponent(MyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

### Testing Component Inputs

```typescript
it('should display the title from input', () => {
  fixture.componentRef.setInput('title', 'Test Title');
  fixture.detectChanges();

  const titleElement = fixture.nativeElement.querySelector('h1');
  expect(titleElement.textContent).toContain('Test Title');
});
```

### Testing with Signals

```typescript
it('should update computed value when signal changes', () => {
  const count = signal(0);
  const doubled = computed(() => count() * 2);

  expect(doubled()).toBe(0);

  count.set(5);
  expect(doubled()).toBe(10);
});
```

## Testing Services with HTTP

```typescript
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { provideHttpClient } from '@angular/common/http';

describe('DataService', () => {
  let service: DataService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        DataService,
        provideHttpClient(),
        provideHttpClientTesting(),
      ],
    });

    service = TestBed.inject(DataService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should fetch data', () => {
    const mockData = { id: 1, name: 'Test' };

    service.getData().subscribe(data => {
      expect(data).toEqual(mockData);
    });

    const req = httpMock.expectOne('/api/data');
    expect(req.request.method).toBe('GET');
    req.flush(mockData);
  });
});
```

## Testing Pipes

```typescript
describe('MyPipe', () => {
  let pipe: MyPipe;

  beforeEach(() => {
    pipe = new MyPipe();
  });

  it('should transform value correctly', () => {
    expect(pipe.transform('input')).toBe('expected output');
  });

  it('should handle null values', () => {
    expect(pipe.transform(null)).toBe('');
  });
});
```

## Testing DOM and User Interactions

```typescript
it('should handle click events', () => {
  const button = fixture.nativeElement.querySelector('button');
  button.click();
  fixture.detectChanges();

  expect(component.clicked()).toBe(true);
});

it('should handle input events', () => {
  const input = fixture.nativeElement.querySelector('input');
  input.value = 'test value';
  input.dispatchEvent(new Event('input'));
  fixture.detectChanges();

  expect(component.inputValue()).toBe('test value');
});
```

## Testing Asynchronous Code

```typescript
import { fakeAsync, tick } from '@angular/core/testing';

it('should handle async operations', fakeAsync(() => {
  component.loadData();

  tick(1000);
  fixture.detectChanges();

  expect(component.data()).toBeDefined();
}));
```

## Best Practices

### ✅ DO

- Use descriptive test names that explain behavior
- Test edge cases and error states
- Keep tests independent — no shared state between tests
- Use beforeEach for common setup
- Clean up after tests (unsubscribe, clear mocks)
- Test accessibility attributes where relevant
- Mock external dependencies

### ❌ DON'T

- Test implementation details (private methods, internal state)
- Write tests that depend on execution order
- Use arbitrary timeouts (use fakeAsync/tick instead)
- Test framework code (Angular internals)
- Write overly complex test setups
- Ignore failing tests or skip them without reason

## Test Organization

```
src/app/
├── feature/
│   ├── feature.component.ts
│   ├── feature.component.spec.ts
│   ├── feature.service.ts
│   └── feature.service.spec.ts
├── shared/
│   ├── pipes/
│   │   ├── my.pipe.ts
│   │   └── my.pipe.spec.ts
```

## Related Documentation

- [State management](/state-management.md) — Testing signals and reactive patterns
- [API communication](/api-communication.md) — Testing HTTP calls
