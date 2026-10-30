---
type: Frontend Reference
title: PWA Architecture
description: Avanza Bank PWA stack — Angular 19+, signals, Mint components, shared code, naming, and agent instructions.
tags: [architecture, pwa, angular, mint]
---

# Project Guidelines: Avanza Bank PWA

Avanza Bank PWA is a Progressive Web App for Avanza's financial services.

## Architecture

- Angular 19+ with built-in control flow syntax: `@if`, `@for`, `@switch`
- Angular Signals for state management (see [state management](/state-management.md))
- Mint Component Library for reusable UI components
- Mint Foundation design system for styling and theming
- `src/shared` for shared code across domains
- SCSS for styling, TypeScript with `strict mode` enabled
- New components, directives, and pipes are standalone by default (Angular 19+) — omit the `standalone` property; set `standalone: false` only for module-declared components (see [file organization](/file-organization.md))

## General Guidelines

- Prioritize simplicity, readability, and performance
- Follow DRY principles with proper error handling
- Embrace Signals, Reactivity, and Functional Programming
- Immutable data handling for inputs, event emitters for outputs
- Use Mint components instead of creating new ones
- Break complex pages into smaller, reusable components
- Only do what is asked — do not refactor unless explicitly requested

## Documentation

- Add meaningful comments for complex logic only
- Document assumptions or limitations as code comments
- For shared PWA components, document in the [pwa-shared-code](/../pwa-shared-code/index.md) bundle

## Naming Conventions

- Descriptive and consistent naming
- Follow Angular and TypeScript conventions
- Avoid abbreviations unless widely recognized

## Agent Instructions

- Load knowledge on demand via `knowledge-lookup` or by reading concept files from this bundle
- NEVER guess how to use a component or utility class — read the relevant knowledge first
- NEVER import or use a module you don't have documentation for — ask the user
- **NEVER modify, delete, or create files inside existing feature directories** when implementing a new feature. Create a NEW directory at the appropriate level
- Never import unused services or modules
- Use semantic HTML elements — avoid divs for everything
- Never refactor code unless explicitly asked

### Do's and Don'ts

1. Unsure about a component

    ❌ **Don't:**

    ```html
    <loading-indicator *ngIf="data().state === 'loading'" />
    ```

    ✅ **Do:**

    ```html
    @if (data().state === 'loading') {
      <!-- Insert loading indicator here -->
    }
    ```

    Leave a comment if missing documentation. Ask the user if the component is critical.

2. Unsure about a Mint Foundation utility class

    ❌ **Don't:** Guess class names

    ```html
    <div class="bg-blue-500 text-white p-4">
    ```

    ✅ **Do:** Read [beta-mint-knowledge](/../beta-mint-knowledge/index.md) token docs first

    ```html
    <div class="mint-font-detail-small mint-text-discreet">
    ```

## Existing Frameworks

### Mint Foundation

Read the relevant docs **before** writing any styling code:

- [Color tokens](/../beta-mint-knowledge/color-tokens.md)
- [Typography tokens](/../beta-mint-knowledge/typography-tokens.md)
- [SCSS conventions](/../beta-mint-knowledge/scss-conventions.md)

### Mint Component Library

Presentation-only ("dumb") components. **Required** to use when possible. Priority: Mint > Shared Code > New component.

- Full list: [beta-mint-components](/../beta-mint-components/index.md)
- When answering questions about Mint, link to [Mint Website](http://mint.avanza.se/#/components/{name_of_component})

### Shared Code

Shared folder (`src/app/shared`) for cross-domain reuse. Code is never imported across domains (a domain = a folder in `src/app`).

- Catalog: [pwa-shared-code](/../pwa-shared-code/index.md)

### RxJS

RxJS patterns are documented separately. See [RxJS best practices](/rxjs.md) when working with Observables.
