---
type: Frontend Reference
title: Page Templates
description: create-page script, base/sub/flow page setup, flow page configuration and navigation.
tags: [pages, flow-page, pwa, angular]
---

# Page Templates

There are three types of pages available for this project: `basePage`, `subPage`, or `flowPage`.

**Always use the `create-page` CLI script** when creating new pages. Do NOT try to create a `basePage`, `subPage`, or `flowPage` yourself.

UX mockups for flow pages: [flow-overlay on Mint website](http://mint.avanza.se/#/styleguides/view-type-flow-overlay)

---

## `create-page` Script

This script streamlines the process of creating a new page module within the Avanza PWA project.

### Prerequisites

- You should be in any directory inside of `src/app` in your terminal when running this script.

### How to Run

Without arguments:

```bash
npm run create-page
```

With arguments:

```bash
npm run create-page -- -- --moduleName MyNewPageModule --moduleDescription "My new module" --pageType subPage
```

For a flow page:

```bash
npm run create-page -- -- --moduleName MyNewFlowModule --moduleDescription "My new flow" --pageType flowPage --flowPageSteps 3 --flowOverlayUrl "my-flow-overlay.html"
```

### Always run the script in the folder you want to create the page in

❌ **Don't:** Create the page in the wrong folder like the project root

```bash
cd /c/development/pwa && npm run create-page -- -- --moduleName PensionTransferPageModule --moduleDescription "Pension transfer page" --pageType subPage
```

✅ **Do:** Make sure you are in the correct folder, for example `src/app/pension/`. Then run the script from there.

```bash
npm run create-page -- -- --moduleName PensionTransferPageModule --moduleDescription "Pension transfer page" --pageType subPage
```

### Arguments

- **`--moduleName`:** The name of the new Angular module.
    - For `basePage` and `subPage`, end with `PageModule` (e.g., `MyNewPageModule`).
    - For `flowPage`, end with `FlowModule` (e.g., `MyNewFlowModule`).
- **`--moduleDescription`:** Human-readable description for the CQ page dialog dropdown.
- **`--pageType`:** `basePage`, `subPage`, or `flowPage`.
- **`--flowOverlayUrl`:** Required when `--pageType` is `flowPage`. Should end with `.html`.

### Output

Upon successful execution, the script will:

- Generate module and component files in the current working directory
- Update `dialog.xml` to include the new module
- Update `navigation-page-modules.routing.ts` to register routing
- Display a "Script ran successfully." message

> **Note to AI agents:** If the script outputs nothing, it means it ran successfully. Check for the sentinel string `__CURSOR_DONE__` on stdout. Always assume success and verify by searching for the new module in the codebase.

### Important Considerations

- **Current Working Directory:** The script places files based on your CWD. A new folder with the page name is created in the current directory.
- **Duplicate Modules:** The script checks for duplicates in `dialog.xml` and `navigation-page-modules.routing.ts` and exits without changes if found.
- To access a newly created page locally, run `npm run start:clean` first.
- If not given a page type, assume `subPage`.
- The script will fail if used outside of `src/app`.

---

## Flow Page Reference

A Flow Page is a specialized page type for guided, multi-step flows.

### Key Features

- Toolbar at the top with back, close, or cancel buttons
- Confirmation dialog when clicking cancel
- "Swipe down to close" on the first view (disabled on subsequent steps)
- Animation when entering/exiting and between steps
- Swipe-to-go-back on iOS between steps
- Progress bar under the toolbar (can be hidden)

### Manual Setup (Reference Only)

For modifying existing flow pages. New flows should use `create-page`.

#### 1. Configure page module

```typescript
import { FlowPageModule, FlowPageGuard } from '@avanzabank/pwa-page-template-library';

@NgModule({
    imports: [
        RouterModule.forChild([
            {
                path: '',
                component: MyPageComponent,
                canActivate: [FlowPageGuard],
                data: { flowOverlayUrl: 'flow-overlay/url-to-flow.html' },
                children: [
                    { path: '', component: Step1Component, data: { flowPageStep: 1 } },
                    { path: '2', component: Step2Component, data: { flowPageStep: 2 } },
                ],
            },
        ]),
        FlowPageModule,
    ],
    declarations: [MyPageComponent, Step1Component, Step2Component],
})
export class MyPageModule {}
```

#### 2. Add routes to `navigation-page-modules.routing.ts`

```typescript
// Flow overlay outlet
{
  path: 'flow-overlay/url-to-flow.html',
  outlet: 'flow-overlay',
  loadChildren: () => import('../../x/y/z.module').then((m) => m.ZModule)
}

// Standard route (same URL without 'flow-overlay/')
{
  path: 'url-to-flow.html',
  loadChildren: () => import('../../x/y/z.module').then((m) => m.ZModule),
}
```

#### 3. Page component template

```html
<aza-flow-page [showProgressBar]="true" [maxSteps]="3" />
```

#### 4. Step component template

```html
<aza-flow-page-step
  [theme]="'discreet'"
  [backButton]="true"
  [actionButton]="'cancel'"
  [transparencyAllowed]="false"
  [title]="'A title always visible in the toolbar'"
  [includePageContainer]="true">
  <aza-flow-page-step-header>
    <h1 class="mint-font-heading-large">Step 1 Title</h1>
  </aza-flow-page-step-header>
  <!-- Step content -->
</aza-flow-page-step>
```

#### Step input properties

- **theme**: `"default"` | `"discreet"`
- **backButton**: `true` / `false`
- **actionButton**: `"none"` | `"cancel"` | `"close"`
- **transparencyAllowed**: `true` / `false`
- **title**: Toolbar title (independent of scrolling)
- **includePageContainer**: `true` / `false` — centers content by default

### Footer

```html
<aza-flow-page-fixed-footer>
  <a azaRouterLink="2" mintButton theme="primary" type="button">Continue</a>
</aza-flow-page-fixed-footer>
```

Must be a direct child of `aza-flow-page-step`.

### Navigation Between Steps

**Relative paths:**

```html
<a azaRouterLink="2" mintButton theme="primary" type="button">Continue</a>
```

**Programmatic:**

```typescript
this.router.navigate(['2'], { relativeTo: this.activatedRoute });
```

### Navigating to Another Flow

```html
<a azaRouterLink="/money/deposit.html" azaCtaButton="primary">Deposit money</a>
```

Add `azaReturnHereWhenFlowsClose` if the linking flow should also close when the linked flow closes.

### Refreshing Data

```html
<aza-flow-page-step (refreshOpportunity)="refreshData()">
```

### Closing a Flow

```typescript
flowOverlayAreaService.close(redirectUrl?: string);
```

### Local Development

1. Run `npm run start:clean`
2. Navigate to `http://localhost:4200/{name_of_flow_page_module}.html`
3. Ensure `flowOverlayUrl` is configured in `navigation-page-modules.routing.ts`
4. Restart devserver after routing changes
5. Add the subPage to active modules in devserverconfig

### App-Friendly Flows

Add a regex pattern to `APP_FRIENDLY_FLOWPAGE_REGEXP` in pwa-platform-library so apps open the flow natively instead of in a browser.

---

## Module-Declared Components

Page components generated by `create-page` use `standalone: false` and must be added to the module's `declarations` array, not `imports`. See [file organization](/file-organization.md) for standalone vs module-declared rules.
