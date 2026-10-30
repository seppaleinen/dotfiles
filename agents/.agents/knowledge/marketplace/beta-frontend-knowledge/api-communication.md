---
type: Frontend Reference
title: API Communication
description: httpResource patterns for PWA — service/component split, parameterized URLs, caching, mutations.
tags: [api, http, httpResource, angular, signals]
---

# Backend Integration and API Calls

> Complements [PWA architecture](/architecture.md) and [state management](/state-management.md). Focuses specifically on **how** to fetch data from backend services.

## Overview

Use Angular's built-in **`httpResource`** for fetching backend data.

> **Requires Angular 22+.** `httpResource` is stable from Angular 22. It was experimental in 19–21. Do not use this pattern in older projects.

- Reactive: the request URL is a function, so it updates when its dependencies (typically signals) change.
- Loading, error, and value are exposed as signals on the resource.
- Returning `undefined` from the request function skips the network call until required parameters are available.

Services expose a **function that returns** an `httpResource`. The component that calls that function owns the resource instance.

## Service and Component Split

- **Service:** build the URL and return `httpResource<T>(() => ...)`. Do not keep the resource as a service field.
- **Component:** call the service function once (field initializer or constructor) and keep the returned resource for the component lifetime.
- **Parameters:** pass functions (usually signals) into the service function, not raw values.
- **Retention:** wrap with `resourceWithRetention` only when the previous value should stay visible during reload or URL change. `resourceWithRetention` is **not** an Angular API — it is a project-specific wrapper (see `src/app/shared/framework`).

```ts
// Service
newsFilters() {
  return httpResource<NewsScreenerFiltersRaw>(() => {
    return '/_api/news-screener/filters';
  });
}

// Component
filters = this.newsScreenerService.newsFilters();
```

❌ **Don't** create the resource in the template or store it as shared state on a root service.

✅ **Do** let each component instance hold its own resource.

## Key Features

1. **No request until ready** — return `undefined` when a required parameter is missing.
2. **Loading and error** — `isLoading()`, `error()`, `status()`, `hasValue()`, `value()`.
3. **Reload** — `reload()` fetches again for the current URL.
4. **Reusability** — URL logic lives in the service; UI and resource lifetime live in the component.

## Basic Usage in a Service

```ts
import { Injectable } from '@angular/core';
import { httpResource } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class NewsScreenerService {
  newsFilters() {
    return httpResource<NewsScreenerFiltersRaw>(() => {
      return '/_api/news-screener/filters';
    });
  }
}
```

❌ **Don't** store the resource on the service:

```ts
@Injectable({ providedIn: 'root' })
export class NewsScreenerService {
  filters = httpResource<NewsScreenerFiltersRaw>(() => '/_api/news-screener/filters');
}
```

❌ **Don't** call the factory from the template:

```html
@if (newsScreenerService.newsFilters().hasValue()) { ... }
```

✅ **Do** assign the returned resource to a component field:

```ts
export class NewsScreenerComponent {
  private newsScreenerService = inject(NewsScreenerService);
  filters = this.newsScreenerService.newsFilters();
}
```

## Parameterized URLs

When the URL depends on one or more parameters, take those parameters as **functions that return a value**. They are typically signals.

Return `undefined` from the `httpResource` request when a required parameter is missing.

```ts
holdingsDataForAccount(accountId: () => string | undefined) {
  return httpResource<HoldingsData>(() => {
    const accId = accountId();
    return accId ? `/_api/market-overview/data/holdings/${accId}` : undefined;
  });
}
```

Because a signal is already a function, the component can pass it directly:

```ts
export class HoldingsComponent {
  private holdingsService = inject(HoldingsService);
  accountId = signal<string | undefined>(undefined);
  holdings = this.holdingsService.holdingsDataForAccount(this.accountId);
}
```

## Retaining Loaded Data with `resourceWithRetention`

By default, a reload or URL change can clear the current value while new data is loading. If the resource should keep showing its last loaded value during that time, wrap it in `resourceWithRetention`:

> **Note:** `resourceWithRetention` is **not** part of Angular's public API. It is a project-specific wrapper in this codebase (`src/app/shared/framework`).

```ts
newsArticle(articlePath: () => string | null) {
  return resourceWithRetention(
    httpResource<NewsDetailArticle>(() => {
      const path = articlePath();
      if (!path) {
        return undefined;
      } else {
        return '/_api/news/article' + path;
      }
    })
  );
}
```

Do not wrap every resource. Use `resourceWithRetention` only when keeping the previous value across reload or URL change is desired.

## Consuming the Resource in a Component

```ts
@Component({
  selector: 'aza-news-screener',
  template: `
    @if (filters.isLoading()) {
      <div>Loading filters...</div>
    } @else if (filters.error()) {
      <div>Could not load filters</div>
    } @else if (filters.hasValue()) {
      <!-- render filters.value() -->
    }
    <button (click)="filters.reload()">Refresh</button>
  `,
  standalone: true,
})
export class NewsScreenerComponent {
  private newsScreenerService = inject(NewsScreenerService);
  filters = this.newsScreenerService.newsFilters();
}
```

- Create the resource as a **field initializer** (or in the constructor) so it is created in an injection context.
- Read `value()`, `isLoading()`, `error()`, `status()`, and `hasValue()` in the template. Do not use the `async` pipe with `httpResource`.
- Call `reload()` to force a new request.

## Caching

`httpResource` has **no built-in caching**. This differs from the old `getSignalStream`/`AjaxService`, which cached automatically and invalidated the cache on logout.

- Each component that calls the service factory gets its **own** resource and makes its **own** HTTP call.
- There is **no automatic cache invalidation** on logout.
- `resourceWithRetention` keeps the last value visible during a reload; it is **not** a shared cache.

If several components need the **same** shared/cached data, expose a single resource from a `providedIn: 'root'` service:

```ts
@Injectable({ providedIn: 'root' })
export class SharedNewsFiltersStore {
  readonly filters = httpResource<NewsScreenerFiltersRaw>(() => '/_api/news-screener/filters');
}
```

Components then inject the store and read `store.filters`. Reset shared state on logout yourself if the data is user-specific.

## Mutations (POST, PUT, PATCH, DELETE)

`httpResource` is for reactive **reads** only. For writes, inject `HttpClient` and call the verb method directly. After a successful mutation, `reload()` the affected resource:

```ts
@Injectable({ providedIn: 'root' })
export class NewsScreenerService {
  private http = inject(HttpClient);

  saveFilters(payload: NewsScreenerFilters) {
    return this.http.post<void>('/_api/news-screener/filters', payload);
  }
}
```

```ts
export class NewsScreenerComponent {
  private service = inject(NewsScreenerService);
  filters = this.service.newsFilters();

  save(payload: NewsScreenerFilters) {
    this.service.saveFilters(payload).subscribe({
      next: () => this.filters.reload(),
      error: (err) => { /* handle error */ },
    });
  }
}
```

## Tips and Best Practices

1. **Prefer `httpResource` for new fetch code** — aligns with the Signal-First approach.
2. **Keep components thin** — services define how to fetch; components present data and handle user actions.
3. **Type your data** — always specify `<T>` on `httpResource<T>()`. Use array shorthand (`Type[]`), not `Array<Type>`.
4. **Gate requests with `undefined`** — if a required parameter is not ready, return `undefined`.
5. **Pass parameter getters, not values** — `() => string | undefined` (a signal is valid).
6. **One resource per consumer** — each component that needs the data calls the service function once.

## Legacy Patterns

The previous `getSignalStream` and `getRxStream` (`AjaxService`) patterns are removed for new code. **Do not use these patterns for new code** — migrate to `httpResource`.
