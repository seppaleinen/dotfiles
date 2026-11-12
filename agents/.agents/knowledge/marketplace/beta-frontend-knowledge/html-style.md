---
type: Frontend Reference
title: HTML Style
description: PWA HTML template conventions — Mint utility classes, self-closing tags, Swedish copy, @if rules.
tags: [html, templates, angular, mint]
---

# HTML Template Guidelines

## Libraries to Use

- For typography changes, read [typography tokens](/../beta-mint-knowledge/typography-tokens.md)
- For spacing changes, read [SCSS conventions](/../beta-mint-knowledge/scss-conventions.md) and use Mint spacing utility classes

### Spacing

❌ **Don't** use hardcoded values for spacing in SCSS:

```scss
.my-class {
    margin-bottom: 12px;
}
```

✅ **Do** use Mint Foundation utility classes:

```html
<div class="mint-margin-bottom-16">
    <!-- content -->
</div>
```

### Typography

❌ **Don't** use hardcoded font values in SCSS:

```scss
.my-class {
    font-size: 16px;
}
```

✅ **Do** use Mint Foundation utility classes:

```html
<div class="mint-font-paragraph-medium">
    <!-- content -->
</div>
```

> Reading token documentation **before writing any code** related to typography or spacing is required.

## Copy

- All text displayed to end users must be in **Swedish** — including aria labels, button text, etc.
- All code (comments, variables) must be in **English**
- For tone and copy patterns, see [beta-mint-knowledge/ux-writing](/../beta-mint-knowledge/ux-writing/copy.md)

## Closing Tags

This project uses `eslint@angular-eslint/template/prefer-self-closing-tags`. Always use self-closing tags for elements with no content — including custom Angular components and web components.

❌ **Don't:**

```html
<aza-custom-component></aza-custom-component>
<mint-custom-component></mint-custom-component>
<img src="logo.png" alt="Logo"></img>
```

✅ **Do:**

```html
<aza-custom-component />
<mint-custom-component />
<img src="logo.png" alt="Logo" />
```

## Function Calls in Templates

**Never call functions directly in templates** unless it's an action event handler or accessing a signal value.

❌ **Don't:**

```html
<div>{{ getFormattedDate() }}</div>
<span [class.active]="isActive()"></span>
<p>{{ calculateTotal(items) }}</p>
```

✅ **Do:**

```html
<div>{{ formattedDate() }}</div>
<span [class.active]="isActive()"></span>
<button (click)="handleClick()">Click me</button>
```

> Signal values like `mySignal()` are acceptable — signals are reactive primitives, not arbitrary computation functions.

## `@if` Blocks Must Contain Only One Node

Each `@if` block must contain exactly **one root node** for content projection to work correctly.

❌ **Don't:**

```html
@if (condition) {
  <li someDirective>...</li>
  <li someDirective>...</li>
}
```

✅ **Do:**

```html
@if (condition) {
  <li someDirective>...</li>
}
@if (condition) {
  <li someDirective>...</li>
}
```

## Important Notes

- There are no Mint helper classes for aligning content. Use flexbox or grid in the SCSS file.
- Classes like `.mint-align-left`, `.mint-align-right`, `.mint-align-center` do **not** exist.
- Never assume a helper class exists — verify in [beta-mint-knowledge](/../beta-mint-knowledge/index.md).

## Related Documentation

- [TypeScript style](/typescript-style.md) — computed values and control flow
- [App-level accessibility](/accessibility-app-level.md)
