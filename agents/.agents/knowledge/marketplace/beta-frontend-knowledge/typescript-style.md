---
type: Frontend Reference
title: TypeScript Style
description: PWA TypeScript conventions — strict typing, OnPush, control flow, inject(), computed values.
tags: [typescript, angular, style]
---

# TypeScript Best Practices

## Rules

- Assume strict TypeScript rules are in place.
- Store any result that will be used multiple times in a local variable — especially important with signals, as TypeScript's type narrowing may lose track of earlier null checks if a signal call is repeated.
- Always handle potential undefined/null values defensively.
- When working with potentially undefined objects or arrays, provide fallback values.
- Use the nullish coalescing operator (`??`) when accessing properties that might be undefined: `(array?.length ?? 0) > 0`
- **Prettier / empty blocks:** Use `{}` for empty class bodies, constructors, and blocks — not `{ }` (spaced).

❌ **Don't:**

```ts
userColor = computed(() => {
    if (!this.userService().getUser()?.preferences?.favoriteColor) {
        return 'unknown';
    }
    return this.userService().getUser()?.preferences?.favoriteColor;
});
```

✅ **Do:**

```ts
userColor = computed(() => {
    const user = this.user();

    if (!user?.preferences?.favoriteColor) {
        return 'unknown';
    }

    return user.preferences.favoriteColor;
});
```

## Change Detection

- Always use `ChangeDetectionStrategy.OnPush` for new components
- Be cautious with `markForCheck()` and `detectChanges()` — use sparingly and document why
- Always consider the central role of signals in triggering updates

❌ **Don't use legacy structural directives** (`*ngIf`, `*ngFor`, `*ngSwitch`):

```ts
@Component({
    template: `
        <ul>
            <li *ngFor="let item of items">{{ item }}</li>
        </ul>
    `,
})
export class ItemListComponent {
    items = ['Item1', 'Item2'];
}
```

✅ **Do use control flow syntax** (`@if`, `@for`, `@switch`) with signals:

```ts
@Component({
    template: `
        <ul>
            @for (item of items()) {
                <li>{{ item }}</li>
            }
        </ul>
        <p>Total Items: {{ totalItems() }}</p>
    `,
    changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ItemListComponent {
    items = signal<string[]>(['Item1', 'Item2']);
    totalItems = computed(() => this.items().length);

    addItem(newItem: string) {
        this.items.update((currentItems) => [...currentItems, newItem]);
    }
}
```

> Using `*ngIf`, `*ngFor` etc. is deprecated. Never do this!

## Avoiding Call Expressions in Templates

Using call expressions in templates forces Angular to repeatedly execute functions during change detection. Use signals and computed values instead.

1. **Use Computed Values**

    ❌ `<p>{{getFullName()}}</p>` → ✅ `<p>{{fullName()}}</p>`

2. **Pre-compute Conditions**

    ❌ `@if (items().length > 3 && checkStatus())` → ✅ `@if (shouldShowContent())`

3. **Use Pure Pipes for Transformations**

    ❌ `{{formatPrice(amount())}}` → ✅ `{{amount() | currencyFormat}}`

4. **Handle Lists**

    ❌ `@for (item of items().slice(0,10))` → ✅ `@for (item of limitedItems())`

## Dependency Injection

Use Angular's `inject()` function instead of constructor injection in modern Angular (18+).

✅ **Preferred:**

```typescript
@Component({...})
export class MyComponent {
    private myService = inject(MyService);
    private router = inject(Router);
}
```

❌ **Avoid in new code:**

```typescript
export class MyComponent {
    constructor(
        private myService: MyService,
        private router: Router
    ) {}
}
```

### Valid Injection Contexts

✅ Field initializers, constructor body, factory functions

❌ Lifecycle hooks, regular methods, event handlers, callbacks

## Types and Interfaces

- Everything should be typed — never use `any`
- Use `Type[]` syntax instead of `Array<Type>`
- Define reusable interfaces instead of inline object types

❌ **Don't:**

```ts
monthlySavings: Array<{ amount: number; date: string }>;
```

✅ **Do:**

```ts
monthlySavings: Monthlysaving[];

interface Monthlysaving {
    amount: number;
    date: string;
}
```

## Refactoring Guidelines

- Never refactor code not relevant to the task at hand
- Always prioritize solving the task at hand
- If you notice a code smell, gently notify the user rather than fixing it unprompted

## Related Documentation

- [State management](/state-management.md)
- [HTML style](/html-style.md)
