---
type: Frontend Reference
title: State Management
description: Signal-first state management in Angular — inputs, computed, effects, immutability, and service patterns.
tags: [state-management, signals, angular, typescript]
---

# State Management Guidelines

Embracing Signals, Reactivity, and Functional Programming in Angular.

## Core Principles

1. **Signal-First Approach for State Management:**
    - Prioritize Signals for managing component-local state and derived data.
    - Favor `signal()`, `computed()`, and `effect()` over RxJS Subjects/BehaviorSubjects for simple state management scenarios within components.
    - Use `input<T>()` and `model<T>()` for component inputs and two-way binding, respectively.

2. **Embrace Immutability (Where Practical):**
    - When working with signal values that are objects or arrays, encourage immutability by creating new instances when updating. This enhances predictability and simplifies debugging.

3. **Functional Component Logic:**
    - Strive for pure functions within `computed()` to ensure predictable derived values. Avoid side effects within `computed()`.
    - Use functional array methods (`map`, `filter`, `reduce`, etc.) for transforming and manipulating signal values whenever feasible.
    - Favor declarative code over imperative code. Express *what* you want to achieve rather than *how* to achieve it.

4. **Judicious Use of `effect()` for Side Effects:**
    - Reserve `effect()` for true side effects (e.g., logging, interacting with external APIs, imperatively manipulating the DOM outside of Angular's rendering).
    - Be mindful of the execution frequency of effects and avoid creating infinite loops by updating signals within the same effect that depends on them.
    - Consider using `untracked()` within effects if you need to access a signal's value without creating a dependency.

5. **Leverage Functional Reactive Programming (FRP) Principles:**
    - Think of your application as a flow of data transformations driven by signal changes.
    - Connect signals and computed values to create reactive pipelines.
    - Let data flow from component to component using signals as inputs to derived values and effects.

## Component Structure and Best Practices

### Input and Output Signals

- **Prefer `input()` over `@Input()`** for component inputs. Mark inputs as `required()` where appropriate.

    ❌ **Don't:**

    ```ts
    @Input() name: string;
    ```

    ✅ **Do:**

    ```ts
    name = input.required<string>();
    ```

- **Prefer `EventEmitter` combined with a signal for outputs.** While direct signal outputs might seem tempting, using `EventEmitter` maintains a clear separation of concerns for event emission.

### Component Logic with Signals

- Centralize component state within signals.
- Use `computed()` for any derived data based on component inputs or internal state signals.
- Keep component template logic simple, relying on signal values and `async` pipe (if necessary for Observables).

### Services and State Management (Beyond Component-Local)

- **Consider Signal-Based Services for Shared State:** For simple shared state between components, services can hold signals.
- **When RxJS is Necessary:** For complex asynchronous operations, handling multiple events over time, or integrating with existing RxJS-heavy code, continue to use RxJS Observables. Use `toSignal()` and `toObservable()` for interoperability when needed and always ask the user before refactoring existing RxJS code.

## Data Handling and Transformations

### Functional Data Transformations

Example for reduce:

❌ **Don't:**

```ts
let total = 0;
this.items().forEach(item => { total += item.price; });
```

✅ **Do:**

```ts
const items = signal([{ price: 10 }, { price: 20 }, { price: 30 }]);
const total = computed(() => items().reduce((acc, item) => acc + item.price, 0));
```

Example for immutable array updates:

❌ **Don't:**

```ts
this.items().push(newItem);
```

✅ **Do:**

```ts
const items = signal([{ price: 10 }, { price: 20 }]);
items.update(currentItems => [...currentItems, newItem]);
```

### Asynchronous Data with Signals

- Prefer `httpResource` for HTTP reads. See [API communication](/api-communication.md).
- Use `toSignal()` only when converting an existing Observable (not HTTP fetch) into a signal.

❌ **Don't:**

```ts
this.http.get('/api/data').subscribe(data => { this.items = data; });
```

✅ **Do:**

```ts
private dataService = inject(DataService);
items = this.dataService.items();
```

## Testing

1. **Unit Testing Signals and Computed Values:** Test signal values directly and ensure `computed()` values update correctly based on their dependencies.
2. **Testing Effects:** Focus on testing the side effects triggered by `effect()`, not the effect itself.
3. **Component Testing:** Test component interactions based on signal changes and updates.

## When to Deviate

While we aim to heavily emphasize signals and FP, there are situations where sticking to Angular's conventional patterns or using RxJS is more appropriate:

- **Complex Asynchronous Operations:** RxJS shines when dealing with intricate asynchronous logic involving multiple streams, transformations, and error handling.
- **Direct DOM Manipulation (Outside of Effects):** Minimize direct DOM manipulation outside of Angular's rendering lifecycle.

## Backend Integration

- **`httpResource`:** Prefer Angular's built-in `httpResource` to fetch data from APIs. See [API communication](/api-communication.md).
- **`HttpClient`:** Use `HttpClient` for mutations (POST/PUT/PATCH/DELETE), or if explicitly asked for by the user.
- **Use services to manage API calls:** Encapsulate API call logic within services.
- **Be rigorous with type checking:** Ensure that API responses are correctly typed.
- **Handle loading and error states:** Use the resource's `isLoading()`, `error()`, and `hasValue()` when fetching with `httpResource`.

## Example

```ts
import { Component, input, computed, effect } from '@angular/core';

@Component({
  selector: 'app-signal-example',
  template: `
    <p>Hello, {{ fullName() }}!</p>
    <button (click)="incrementAge()">Increment Age</button>
  `,
  standalone: true,
})
export class SignalExampleComponent {
  name = input.required<string>();
  age = input(20);

  fullName = computed(() => `${this.name()} (Age: ${this.age()})`);

  incrementAge() {
    this.age.update(a => a + 1);
  }

  constructor() {
    effect(() => {
      console.log(`Age changed to: ${this.age()}`);
    });
  }
}
```
