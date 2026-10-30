---
type: Frontend Reference
title: Error Handling
description: PWA error handling — HTTP errors, user feedback, recovery, Mint error UI components.
tags: [error-handling, http, angular, mint]
---

# Error Handling Guidelines

This document outlines the error handling patterns and best practices used in the Avanza PWA.

## Error Handling Philosophy

- **Fail gracefully** — The app should continue to function even when parts fail
- **Inform the user** — Always provide meaningful feedback about errors
- **Log for debugging** — Capture error details for troubleshooting
- **Recover when possible** — Implement retry and fallback mechanisms

## Types of Errors

| Error Type | Example | Handling Strategy |
|------------|---------|-------------------|
| **HTTP Errors** | API failures, timeouts | Show error state, retry option |
| **Validation Errors** | Invalid form input | Show field-level errors |
| **Business Logic Errors** | Insufficient funds | Show contextual message |
| **Unexpected Errors** | JavaScript exceptions | Global error handler |

## HTTP Error Handling

Use `httpResource` for reads. See [API communication](/api-communication.md).

### Component: loading, error, and user-facing messages

```typescript
import { HttpErrorResponse } from '@angular/common/http';
import { Component, computed, inject } from '@angular/core';

@Component({...})
export class MyComponent {
  private dataService = inject(DataService);
  data = this.dataService.data();

  errorMessage = computed(() => {
    const error = this.data.error();
    if (!error) {
      return null;
    }
    if (!(error instanceof HttpErrorResponse)) {
      return 'Ett oväntat fel uppstod';
    }
    if (error.status === 0) {
      return 'Kunde inte ansluta till servern';
    }
    if (error.status === 401) {
      return 'Du är inte inloggad';
    }
    if (error.status === 403) {
      return 'Du har inte behörighet';
    }
    if (error.status === 404) {
      return 'Resursen hittades inte';
    }
    if (error.status >= 500) {
      return 'Serverfel, försök igen senare';
    }
    return 'Ett oväntat fel uppstod';
  });
}
```

Template: `@if (data.isLoading())`, `@if (data.error())`, `@if (data.hasValue())`. Retry with `data.reload()`.

❌ **Don't** subscribe to HTTP Observables and mirror loading/error into a manual signal.

✅ **Do** read `isLoading()`, `error()`, and `hasValue()` on the `httpResource` the component owns.

## Component Error Display

### Using Mint Components

#### Infobox for Errors

```html
@if (errorMessage()) {
  <mint-infobox theme="error" [dismissible]="false">
    <span title>Något gick fel</span>
    <span body>{{ errorMessage() }}</span>
    <button mintTextButton (click)="data.reload()">
      <mint-icon mintButtonIconLeft name="refresh" size="small" />
      Försök igen
    </button>
  </mint-infobox>
}
```

#### Loading State Wrapper

```html
<mint-loading-state-wrapper
  [state]="dataState()"
  [errorMessage]="'Kunde inte ladda data'"
  (retry)="loadData()">

  @if (data(); as items) {
    <mint-list>
      @for (item of items; track item.id) {
        <mint-list-item>{{ item.name }}</mint-list-item>
      }
    </mint-list>
  }

</mint-loading-state-wrapper>
```

#### Empty State

```html
@if (data()?.length === 0) {
  <mint-empty-state>
    <span heading>Inga resultat</span>
    <span body>Det finns ingen data att visa just nu.</span>
  </mint-empty-state>
}
```

## Global Error Handling

### Error Handler Service

```typescript
import { ErrorHandler, Injectable, inject } from '@angular/core';

@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  private logger = inject(LoggingService);

  handleError(error: Error): void {
    this.logger.error('Unhandled error:', error);

    if (this.isCriticalError(error)) {
      this.notificationService.show({
        message: 'Ett oväntat fel uppstod',
        theme: 'error',
      });
    }
  }

  private isCriticalError(error: Error): boolean {
    return !error.message.includes('ResizeObserver');
  }
}
```

### HTTP Interceptor for Errors

```typescript
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const authService = inject(AuthService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.status === 401) {
        authService.logout();
        router.navigate(['/login']);
      }

      if (error.status === 503) {
        router.navigate(['/maintenance']);
      }

      return throwError(() => error);
    })
  );
};
```

## Error Recovery Patterns

### Retry

Call `reload()` on the `httpResource` the component owns. Do not pipe RxJS `retry` onto an HTTP Observable.

### Fallback Values

```typescript
settings() {
  return httpResource<Settings>(() => '/_api/settings', {
    defaultValue: DEFAULT_SETTINGS,
  });
}
```

### Partial Loading

Load critical and non-critical data as separate resources. Gate the UI on the critical resource's error state.

## User Feedback Messages

| Scenario | Message (Swedish) |
|----------|-------------------|
| Network error | "Kunde inte ansluta. Kontrollera din internetanslutning." |
| Server error | "Något gick fel. Försök igen senare." |
| Not found | "Sidan hittades inte." |
| Unauthorized | "Du behöver logga in för att fortsätta." |
| Forbidden | "Du har inte behörighet att se detta." |
| Validation | "Kontrollera de markerade fälten." |
| Timeout | "Servern svarade inte. Försök igen." |

## Best Practices

### ✅ DO

- **Always handle errors** at the appropriate level
- **Provide retry options** for recoverable errors
- **Use Swedish messages** for user-facing errors
- **Log errors** with context for debugging
- **Show loading states** while retrying
- **Fail gracefully** — don't break the entire app
- **Use Mint components** for consistent error UI

### ❌ DON'T

- **Don't show technical error messages** to users
- **Don't swallow errors silently** without logging
- **Don't retry infinitely** — set reasonable limits
- **Don't show multiple error notifications** for the same error
- **Don't block the entire UI** for non-critical errors
- **Don't expose sensitive information** in error messages

## Related Documentation

- [Infobox](/../beta-mint-components/references/infobox.md) — Error message display
- [Loading State Wrapper](/../beta-mint-components/references/loading-state-wrapper.md) — Loading/error states
- [Empty State](/../beta-mint-components/references/empty-state.md) — Empty content display
- [API Communication](/api-communication.md) — HTTP patterns
