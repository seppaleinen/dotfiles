# Beta Frontend Knowledge

Reference guidelines for Avanza PWA product code (`pwa/**`) — architecture, patterns, and engineering standards outside the Mint design system.

> Related: Mint design system (tokens, principles, component-level a11y) → [beta-mint-knowledge](/../beta-mint-knowledge/index.md)
>
> Related: per-component Mint API and usage → [beta-mint-components](/../beta-mint-components/index.md)
>
> Related: shared PWA components (`pwa/src/app/shared`) → [pwa-shared-code](/../pwa-shared-code/index.md)

## Architecture & patterns

* [PWA Architecture](/architecture.md) — Angular 18+, signals, Mint priority, shared code, naming conventions
* [State Management](/state-management.md) — Signal-first approach, immutability, functional component logic
* [RxJS Best Practices](/rxjs.md) — Operator chaining, subscription cleanup, common operators
* [API Communication](/api-communication.md) — `httpResource` patterns, service/component split, caching
* [Error Handling](/error-handling.md) — HTTP errors, user feedback, recovery patterns, Mint error UI
* [Forms](/forms.md) — Reactive forms, Mint form integration, validation patterns
* [Routing](/routing.md) — Lazy loading, guards, resolvers, navigation patterns

## Testing & pages

* [Testing](/testing.md) — Unit, component, and integration test patterns for PWA
* [Page Templates](/pages.md) — `create-page` script, base/sub/flow page setup

## File & code style

* [File Organization](/file-organization.md) — Creating and moving files, Git rename detection
* [TypeScript Style](/typescript-style.md) — Strict typing, OnPush, control flow, `inject()`
* [SCSS Style](/scss-style.md) — Mint Foundation usage, responsive design, accessibility in layout
* [HTML Style](/html-style.md) — Utility classes, self-closing tags, Swedish copy, `@if` rules

## Accessibility

* [App-Level Accessibility](/accessibility-app-level.md) — WCAG cheatsheet for PWA templates (buttons, forms, headings). For Mint component a11y → [beta-mint-knowledge/accessibility](/../beta-mint-knowledge/accessibility.md)

## UX writing

* Swedish tone and copy patterns → [beta-mint-knowledge/ux-writing](/../beta-mint-knowledge/ux-writing/copy.md) (canonical source; do not duplicate here)
