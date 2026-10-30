---
type: Frontend Reference
title: Routing
description: Angular routing in PWA — lazy loading, guards, resolvers, navigation, URL conventions.
tags: [routing, angular, navigation]
---

# Routing Guidelines

Routing patterns and best practices used in the Avanza PWA.

## Route Configuration

### Basic Route Structure

```typescript
import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
  },
  {
    path: 'feature',
    loadComponent: () => import('./feature/feature.component').then(m => m.FeatureComponent),
  },
  {
    path: '**',
    redirectTo: '',
  },
];
```

### Lazy Loading Modules

Always use lazy loading for feature modules to improve initial load time:

```typescript
export const routes: Routes = [
  {
    path: 'accounts',
    loadChildren: () => import('./accounts/accounts.routes').then(m => m.ACCOUNTS_ROUTES),
  },
];
```

### Lazy Loading Standalone Components

```typescript
{
  path: 'details/:id',
  loadComponent: () => import('./details/details.component').then(m => m.DetailsComponent),
}
```

## Route Parameters

### Path Parameters

```typescript
import { ActivatedRoute } from '@angular/router';
import { toSignal } from '@angular/core/rxjs-interop';

@Component({...})
export class InstrumentComponent {
  private route = inject(ActivatedRoute);

  instrumentId = toSignal(
    this.route.paramMap.pipe(
      map(params => params.get('instrumentId'))
    )
  );
}
```

### Query Parameters

```typescript
this.router.navigate(['/search'], {
  queryParams: { q: searchTerm, page: 1 },
});

queryParams = toSignal(this.route.queryParamMap);
searchQuery = computed(() => this.queryParams()?.get('q') ?? '');
```

## Route Guards

### Authentication Guard

```typescript
export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  return router.createUrlTree(['/login']);
};
```

### Feature Flag Guard

```typescript
export const featureFlagGuard: CanActivateFn = (route) => {
  const confidenceService = inject(ConfidenceService);
  const router = inject(Router);

  const featureFlag = route.data['featureFlag'];

  if (confidenceService.getBooleanFlag(featureFlag, false)) {
    return true;
  }

  return router.createUrlTree(['/']);
};
```

### Deactivation Guard (Unsaved Changes)

```typescript
export interface CanComponentDeactivate {
  canDeactivate: () => boolean | Observable<boolean>;
}

export const unsavedChangesGuard: CanDeactivateFn<CanComponentDeactivate> = (component) => {
  if (component.canDeactivate && !component.canDeactivate()) {
    return confirm('You have unsaved changes. Are you sure you want to leave?');
  }
  return true;
};
```

## Navigation Patterns

### Programmatic Navigation

```typescript
@Component({...})
export class MyComponent {
  private router = inject(Router);

  navigateToDetails(id: string): void {
    this.router.navigate(['/details', id]);
  }

  navigateWithQueryParams(): void {
    this.router.navigate(['/search'], {
      queryParams: { filter: 'active' },
      queryParamsHandling: 'merge',
    });
  }
}
```

### Router Link in Templates

```html
<a routerLink="/home">Home</a>
<a [routerLink]="['/instrument', instrumentId]">View Instrument</a>
<a [routerLink]="['/search']" [queryParams]="{ q: searchTerm }">Search</a>
<a routerLink="/accounts"
   routerLinkActive="active"
   [routerLinkActiveOptions]="{ exact: true }">
  Accounts
</a>
```

## Resolvers

```typescript
export const instrumentResolver: ResolveFn<Instrument> = (route) => {
  const instrumentService = inject(InstrumentService);
  const instrumentId = route.paramMap.get('instrumentId');

  return instrumentService.getInstrument(instrumentId!);
};

{
  path: 'instrument/:instrumentId',
  component: InstrumentComponent,
  resolve: { instrument: instrumentResolver },
}

resolvedData = toSignal(this.route.data);
instrument = computed(() => this.resolvedData()?.['instrument']);
```

## Best Practices

### ✅ DO

- **Lazy load all feature routes** for better initial load performance
- **Use descriptive route paths** that reflect the content hierarchy
- **Implement guards** for protected routes
- **Use signals** to reactively handle route parameter changes
- **Provide meaningful page titles** via route data or TitleStrategy
- **Handle not-found routes** with a wildcard redirect

### ❌ DON'T

- **Don't nest routes too deeply** — keep URL structure flat when possible
- **Don't put sensitive data in URLs** — use proper state management
- **Don't ignore guard return values** — always handle navigation failures
- **Don't use synchronous resolvers** for heavy data fetching
- **Don't forget to unsubscribe** from route observables (or use signals)

## URL Structure Guidelines

```
/accounts                    # List view
/accounts/:accountId         # Detail view
/accounts/:accountId/edit    # Edit view
/accounts/new                # Create view

/trading/buy/:instrumentId   # Action view
/trading/orders              # Sub-feature list

/settings/profile            # Nested settings
/settings/notifications
```

## Related Documentation

- [PWA architecture](/architecture.md)
- [State management](/state-management.md) — Using signals with routes
