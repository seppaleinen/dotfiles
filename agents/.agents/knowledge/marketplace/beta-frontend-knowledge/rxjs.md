---
type: Frontend Reference
title: RxJS Best Practices
description: Avoid nested subscribes, always clean up with takeUntilDestroyed, common operator selection.
tags: [rxjs, angular, typescript]
---

# RxJS Best Practices

## Avoid Nested Subscribes (Anti-Pattern)

Nested subscribes make code harder to read, maintain, and debug. They also make it difficult to handle errors and unsubscribe properly.

❌ **Don't: Use nested subscribes**

```ts
private runValidations(): void {
    this.service.checkFirst().subscribe((firstResult) => {
        if (!firstResult.valid) {
            this.router.navigate(['error']);
            return;
        }

        this.service.checkSecond().subscribe((secondResult) => {
            if (!secondResult.valid) {
                this.router.navigate(['error']);
                return;
            }

            this.service.checkThird().subscribe((thirdResult) => {
                if (!thirdResult.valid) {
                    this.router.navigate(['error']);
                }
            });
        });
    });
}
```

✅ **Do: Use RxJS operators to chain observables with proper cleanup**

```ts
import { DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { EMPTY, Observable } from 'rxjs';
import { switchMap, tap } from 'rxjs/operators';

export class MyComponent {
    private destroyRef = inject(DestroyRef);

    private runValidations(): void {
        this.service
            .checkFirst()
            .pipe(
                tap((firstResult) => {
                    if (!firstResult.valid) {
                        this.router.navigate(['error']);
                    }
                }),
                switchMap((firstResult): Observable<SecondResult> => {
                    if (!firstResult.valid) {
                        return EMPTY;
                    }
                    return this.service.checkSecond();
                }),
                tap((secondResult) => {
                    if (!secondResult.valid) {
                        this.router.navigate(['error']);
                    }
                }),
                switchMap((secondResult): Observable<ThirdResult> => {
                    if (!secondResult.valid) {
                        return EMPTY;
                    }
                    return this.service.checkThird();
                }),
                takeUntilDestroyed(this.destroyRef)
            )
            .subscribe((thirdResult) => {
                if (!thirdResult.valid) {
                    this.router.navigate(['error']);
                }
            });
    }
}
```

## Always Clean Up Subscriptions

**CRITICAL:** Always use `takeUntilDestroyed(this.destroyRef)` to automatically clean up subscriptions when the component is destroyed.

**Required pattern:**

```ts
import { DestroyRef, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';

export class MyComponent {
    private destroyRef = inject(DestroyRef);

    ngOnInit() {
        this.myService.getData()
            .pipe(
                takeUntilDestroyed(this.destroyRef)
            )
            .subscribe(data => {
                // Handle data
            });
    }
}
```

## Common RxJS Operators

- `switchMap`: Cancels previous inner observable when new value arrives (most common)
- `mergeMap` / `flatMap`: Allows multiple inner observables concurrently
- `concatMap`: Waits for previous inner observable to complete before starting next
- `exhaustMap`: Ignores new values while inner observable is active
- `tap`: Side effects without modifying the stream
- `EMPTY`: Returns empty observable to stop the chain
- `takeUntilDestroyed`: Auto-unsubscribes on component destroy (ALWAYS USE THIS)
