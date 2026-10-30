---
type: Frontend Reference
title: App-Level Accessibility
description: WCAG cheatsheet for PWA templates — buttons, forms, headings, screen reader patterns.
tags: [accessibility, a11y, wcag, pwa]
---

# App-Level Accessibility

WCAG-compliant, accessible code for PWA templates and custom components.

> **Component-level Mint a11y** (touch targets, icon buttons, CDK patterns) → [beta-mint-knowledge/accessibility](/../beta-mint-knowledge/accessibility.md). This document covers **application template patterns** — buttons, links, forms, headings — that apply across PWA code outside Mint component APIs.

## General Guidelines

Proper HTML is an important factor in creating accessible interfaces that work for keyboard navigation and screen readers. At Avanza, buttons, headings, labels, and form fields are the most frequently used elements — and the easiest to get right.

The `mint-screen-reader-only` CSS class visually hides content on screen but keeps it available to screen readers. It is imported globally — no component import needed. Use it when `aria-label` is unconventional or not applicable. It is not suitable for hiding headings or replacing `<label>` on form elements.

> Primarily, always use semantic HTML! `aria-label` has slightly inconsistent behavior across screen readers. iOS screen reader behavior should always be prioritized.

## WCAG Requirements

**Semantic Structure:**
- Use semantic HTML elements (`nav`, `main`, `article`, `section`)
- Create logical heading hierarchy (`h1`–`h6`)
- Implement proper landmark regions

**Interactive Elements:**
- Ensure keyboard navigation support
- Maintain visible focus indicators
- Implement proper focus management
- Support touch and mouse interactions

**ARIA Implementation:**
- Add appropriate ARIA landmarks
- Include descriptive ARIA labels
- Use ARIA states and properties correctly
- Implement ARIA live regions for dynamic content

**Media and Content:**
- Provide descriptive alt text for images
- Ensure proper color contrast ratios
- Support text resizing and zoom
- Include captions and transcripts for media

**Testing Requirements:**
- Verify screen reader compatibility
- Test with keyboard-only navigation
- Ensure functionality at 200% zoom

## Buttons & Links

**A button (`<button>`) has:**
- Click via mouse, touch, SPACE & ENTER keys
- Keyboard/screen reader focus
- Semantic interpretation by screen readers
- Can be `disabled`

**A link (`<a>`) has:**
- Click via mouse, touch, ENTER key
- Keyboard/screen reader focus
- Semantic interpretation by screen readers
- Cannot be `disabled`

**Never disable buttons** to block progression in a form or multi-step flow. Disabled buttons cannot receive keyboard focus, provide no information about what is missing, give no feedback on click, and have low color contrast.

**Recommended pattern:** keep the primary action button enabled and show a validation error when the user attempts to proceed without meeting the requirements. Do not use `[disabled]="form.invalid"` or similar patterns on flow navigation buttons.

Use `disabled` on buttons only in rare cases where the action is genuinely unavailable (e.g. a feature flag or a temporary system state) — not as a substitute for form validation.

> Buttons and links should never be nested within other buttons/links.

### Button or Link?

When a click **only** navigates to a new page, use links. On links, `href` must always be present.

Generally, `(click)` should be used on buttons and never on links. Exceptions: when `(click)` constructs a navigation link and navigates (no additional logic), or when the link has an `href` and `(click)` saves information to the backend. If further logic is needed (modal, form validation), use a button.

#### DON'T

```html
<a (click)="toggleMenu()">
<a (click)="validateFormThenNavigateBasedOnResult()">
<button routerLink="/sida.html">
```

#### DO

```html
<button (click)="toggleMenu()">
<button (click)="validateFormThenNavigateBasedOnResult()">
<a href="#" (click)="concatUrlThenNavigate(/sida.html)">
<a routerLink="/sida.html">
```

### Focus & Click

Buttons/links must receive focus through keyboard navigation and handle clicks with SPACE (not links), ENTER, touch, and mouse. Use `<button>` and `<a>` — custom elements need `tabindex="0"`, `role="button"`, and SPACE/ENTER support.

#### DON'T

```html
<my-custom-component (click)="doSomething()">
<div (click)="doSomething()">
```

#### DO

```html
<button (click)="doSomething()">
  <my-custom-component />
</button>
```

### Clear Description

Buttons/links must have a clear description of what they do, even when text is not visible.

#### DON'T

```html
<a href="...">Try now!</a>
<a href="...">Show more</a>
<button>
  <mint-icon />
</button>
```

#### DO

```html
<a href="...">Try Avanza Auto now!</a>
<a href="...">Show related funds</a>
<button aria-label="Show more services">
  <mint-icon />
</button>
```

## Labels & Form Fields

- Form fields should always have a `label` explaining the purpose
- `placeholder` is not an accessible attribute and cannot replace a `label`
- Buttons should **never** be placed inside a `label`

### Label on Form Elements

Use `<label>` with correct structure, even if text is not visible. `aria-label`/`aria-labelledby` works on form elements but `<label>` is preferred.

#### DON'T

```html
<input placeholder="Search">
<label>Search</label>
<input placeholder="Search">
```

#### DO

```html
<label>
  <span>Search</span>
  <input placeholder="Search">
</label>

<label for="unique-id-on-page">Search</label>
<input id="unique-id-on-page" placeholder="Search">

<!-- Hidden text: add class="mint-screen-reader-only" on the span/label -->
```

### Label on Custom-Built Form Elements

For custom elements like `aza-button-toggle`, use `aria-label`/`aria-labelledby`, not `<label>`. `aza-select` and `aza-account-picker` have a `screenReaderLabel` input.

> Test with a screen reader. `aria-label` is not announced on `role="radiogroup"` on iOS — use detailed `aria-label` on options or `fieldset + legend`.

#### DON'T

```html
<label>
  <span>Are you a PEP?</span>
  <aza-button-toggle>...</aza-button-toggle>
</label>
```

#### DO

```html
<span id="unique-id-on-page">Are you a PEP?</span>
<aza-button-toggle aria-labelledby="unique-id-on-page">...

<aza-button-toggle aria-label="Are you a PEP?">...
```

### Standalone Labels

`<label>` should **never** be used standalone from form fields. Use a heading, `strong`, `small`, or `span` instead.

#### DON'T

```html
<div>
  <label>News</label>
  <p>Body text...</p>
</div>
```

#### DO

```html
<div>
  <strong class="mint-font-form-label">News</strong>
  <p>Body text...</p>
</div>
```

### Grouping Form Fields

Use `fieldset` with `legend` when a label applies to a group of related fields.

### Input for Numbers

`type="number"` is relatively inaccessible. Do not use it.

#### DON'T

```html
<input type="number">
```

#### DO

```html
<input type="text" inputmode="numeric" pattern="[0-9]*">
```

## Headings

Headings define document structure. Differentiate between semantics (HTML) and appearance (SCSS).

#### DON'T

```html
<h1>Page heading</h1>
<!-- h2 is missing -->
<h3>Related content</h3>
<h4>Heading not related to previous</h4>
<div>relevant content without heading</div>
```

#### DO

```html
<h1>Page heading</h1>
<h2 class="mint-font-heading-large">Related content</h2>
<h3>Subheading of the previous h2</h3>
<h2 class="mint-font-heading-medium">Not related to previous h2</h2>
<h2 class="mint-screen-reader-only">Visually hidden heading</h2>
```

## Grouping of Texts

Use `role="presentation"` on a wrapper `div`/`span` when screen readers should read grouped text in one go. **Never** use `role="presentation"` on semantic elements (`h2`, `button`, `li`).

#### DON'T

```html
<h2 class="mint-font-heading-medium">
  <aza-flag [flagCode]="'SE'" />
  Security name
  <span class="mint-font-subhead-medium">
    Today's development
    <span class="mint-text-negative">-0.95%</span>
  </span>
</h2>
```

#### DO

```html
<h2 class="mint-font-heading-medium">
  <div role="presentation">
    <aza-flag [flagCode]="'SE'" />
    Security name
    <span class="mint-font-subhead-medium">
      Today's development
      <span class="mint-text-negative">-0.95%</span>
    </span>
  </div>
</h2>
```

### Screen Reader-Only Text

Screen reader text should be clear and concise — not a direct translation of visible text. Use "pieces" instead of "pcs".

#### DON'T

```html
<span>{{ monthlySaving.numberOfFunds }}&nbsp;pcs funds</span>
```

#### DO

```html
<span aria-hidden="true">{{ monthlySaving.numberOfFunds }}&nbsp;pcs funds</span>
<span class="mint-screen-reader-only">{{ monthlySaving.numberOfFunds }}&nbsp;pieces funds</span>
```

## Code Generation

**When generating HTML:**
- Keep styling consistent — if changing heading level, use `mint-text-styled-as-h*` classes
- Use Avanza/Angular custom components (`routerLink`, `azaRouterLink`)
- All user-facing text (aria-labels, alt-text) must be in Swedish
- Never use aria-labels on custom components — put them on semantically correct tags inside

**When generating CSS:**
- Only SCSS, never pure CSS. Follow [SCSS style](/scss-style.md).

**For all code generation:**
- Prioritize not breaking existing code when making accessibility improvements
- Keep the same formatting as the user's provided code
