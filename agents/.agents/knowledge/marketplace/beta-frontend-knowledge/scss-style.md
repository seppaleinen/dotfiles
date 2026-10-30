---
type: Frontend Reference
title: SCSS Style
description: PWA SCSS conventions — Mint Foundation usage, responsive design, accessibility in layout.
tags: [scss, styling, mint-foundation]
---

# Styling Guidelines

Guidelines for writing SCSS at Avanza using Mint Foundation.

> For full token catalogs, see [beta-mint-knowledge](/../beta-mint-knowledge/index.md) (colors, typography, SCSS conventions).

## General Guidelines

- **Always use SCSS** — variables, nested rules, mixins, functions
- **Always use classes** — never use inline styling

## Mint Foundation

Mint Foundation contains shared styles and SCSS utilities used across all products.

```scss
@use '@avanzabank/mint-foundation/styles/mint';
```

### Typography

Always use the `setFont` mixin combined with predefined font variables:

```scss
h1 {
    @include mint.setFont(mint.$fontHeadingLarge);

    @include mint.phone {
        @include mint.setFont(mint.$fontHeadingMedium);
    }
}
```

See [typography tokens](/../beta-mint-knowledge/typography-tokens.md) for available font variables.

### Responsive Design

Use media queries from Mint Foundation. Create mobile-first designs with base styles for phones and `tabletAndAbove` for larger screens. See [SCSS conventions](/../beta-mint-knowledge/scss-conventions.md).

### Colors

Never set color directly on an element. Use semantic `$color` variables:

```scss
.element {
    color: mint.$colorContentPrimary;
    border-color: mint.$colorStrokePrimary;
}
```

> **NEVER** use hex values — strictly forbidden.

See [color tokens](/../beta-mint-knowledge/color-tokens.md) for the full catalog.

### Spacing

Prefer assigning spacing in the HTML template using predefined classes (`.mint-margin-{value}`, `.mint-margin-top-{value}`) rather than SCSS variables or px/rem/em values.

❌ **Don't:**

```scss
.element {
    margin: $space12;
    padding: 12px;
}
```

✅ **Do:**

```html
<div class="mint-margin-12">
    <p>Hello</p>
</div>
```

> Using px, rem or em values in SCSS for spacing is strictly forbidden. Use predefined HTML classes instead.

If you need to know which classes are available, read [beta-mint-knowledge](/../beta-mint-knowledge/index.md) — do not guess.

## Accessibility & Alignment

Robust and responsive SCSS is important for accessible interfaces that work with zoom and font size changes.

### Height

❌ **Don't** set `height` on elements

✅ **Do** set `min-height` on elements

For equal-height boxes, use `grid` or `flexbox` instead of fixed heights:

```scss
.container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-auto-rows: 1fr;
    grid-gap: 20px;
}
```

### Width

❌ **Don't** set width in pixels on elements that have room to grow

✅ **Do** use rem on elements that should grow with text size (`getPixelValueAsRem` helper available in Mint Foundation)

❌ **Don't** force content into one line when it doesn't fit

✅ **Do** use `flexbox` to let content reflow:

```scss
.container {
    display: flex;
    flex-flow: row wrap;
}
```

Content queries can be used as progressive enhancement:

```scss
.container {
    container-name: shortcut-container;
    container-type: inline-size;
}
@container shortcut-container (max-width: 53ch) {
    .shortcut-button {
        flex-basis: 100%;
    }
}
```

## Related Documentation

- [HTML style](/html-style.md) — spacing and typography utility classes in templates
- [beta-mint-knowledge/scss-conventions](/../beta-mint-knowledge/scss-conventions.md)
