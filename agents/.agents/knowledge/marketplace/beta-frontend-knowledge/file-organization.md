---
type: Frontend Reference
title: File Organization
description: Creating and moving files in PWA — folder structure, naming, Git rename detection, standalone vs module-declared.
tags: [files, organization, angular, git]
---

# File Organization

Guidelines for creating and moving files in the Avanza PWA.

---

## File Creation

### General Guidelines

- Always prefer to create standalone components over new modules

### Clear Folder Structure

- Follow the Angular Style Guide for folder structure and naming conventions
- For each module, create a separate folder with the module name
- Establish a consistent and logical folder structure within each module (components, services, models, pipes, directives)
- For each component, create a separate folder with the component name

### Naming Conventions

- Use meaningful and descriptive names for variables, functions, and classes
- Use camelCase for variables, functions, and methods
- Use PascalCase for class names and interfaces
- Use kebab-case for file names and directories (e.g., `my-component-with-long-name.component.ts`)
- End components with `.component.ts`, services with `.service.ts`, modules with `.module.ts`

### Component Selectors

Always use the prefix `aza` for all custom component selectors.

```typescript
@Component({
    selector: 'aza-my-component',
    templateUrl: './my-component.html',
    styleUrls: ['./my-component.scss'],
    standalone: true,
})
```

> Only use the prefix for the selector, not for file names or class names.

### Standalone vs Module-Declared Components

> ⚠️ **IMPORTANT:** In Angular, the default is `standalone: true`. If the `standalone` property is MISSING or set to `true`, the component IS STANDALONE. You MUST explicitly set `standalone: false` to make it module-declared.

- **Standalone components** (`standalone: true` OR property missing):
    - ✅ Add to `imports` array
    - ❌ NEVER add to `declarations` array

- **Module-declared components** (`standalone: false` EXPLICITLY set):
    - ✅ Add to `declarations` array
    - ❌ NEVER add to `imports` array

**Converting generated page components to module-declared:**

1. Generated component has `standalone: true` (from `create-page`)
2. Change it to `standalone: false` (NOT just delete the line!)
3. Add to `declarations` array in module

### Verify Generated File Paths

The `create-page` script sometimes generates incorrect `templateUrl` and `styleUrls` paths with extra suffixes.

**Always verify after using create-page:**

1. List actual files in the directory
2. Compare with paths in `@Component` decorator
3. Fix mismatches before writing any code

❌ **Incorrect:**

```typescript
templateUrl: './portfolio-health-check-flow-step1-step.component.html',
```

✅ **Correct:**

```typescript
templateUrl: './portfolio-health-check-flow-step1.component.html',
```

---

## File Moves

When moving files between directories, follow these guidelines to ensure Git tracks the changes as **renames** rather than delete + add pairs.

### Core Principle

Git detects renames by comparing deleted files with added files (>= 50% similarity):

1. The old file must be **deleted** (not modified)
2. The new file must be **added** at the new location
3. The content must remain sufficiently similar

> **Never overwrite old files with re-export barrels** if you want them to appear as moved in the MR.

### Step-by-Step Process

1. **Identify all consumers** — search for imports referencing the old path
2. **Move the files** — update internal import paths
3. **Delete the old files** — do not leave re-export barrels
4. **Update all consumers** — import from the new path
5. **Stage and verify rename detection:**

```bash
git add -A
git diff --cached --name-status -M --find-renames=30%
```

Files should appear with an `R` prefix:

```
R100  src/app/old-path/my-file.ts  src/app/shared/new-path/my-file.ts
```

6. **Build verification** — run a build check after moving files

### Do's and Don'ts

❌ **Don't:** Overwrite old files with re-export barrels

```typescript
export { MyModule } from '@shared/new-path/my-module';
```

✅ **Do:** Delete old files and update all consumers

```typescript
// Before:
import { MyModule } from '@app/old-path/my-module';
// After:
import { MyModule } from '@shared/new-path/my-module';
```

### Moving Multiple Related Files

When moving a component with `.ts`, `.html`, and `.scss` files:

- Move **all** related files together
- HTML and SCSS files typically have 100% content similarity (R100)
- `.ts` files will have slightly lower similarity due to updated import paths
