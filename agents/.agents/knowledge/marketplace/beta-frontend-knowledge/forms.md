---
type: Frontend Reference
title: Forms
description: Reactive forms, Mint form integration, validation patterns, and accessibility for PWA forms.
tags: [forms, validation, angular, mint]
---

# Form Validation Guidelines

Form handling and validation patterns used in the Avanza PWA.

## Form Types

| Approach | Use Case |
|----------|----------|
| **Reactive Forms** | Complex forms, dynamic fields, custom validation |
| **Template-driven** | Simple forms, minimal validation |
| **Signal-based** | Simple state, non-form inputs |

**Recommendation:** Use **Reactive Forms** for most cases in this project.

## Reactive Forms Basics

### Setting Up a Form

```typescript
import { Component, inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-my-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [mintForm]="form" (ngSubmit)="onSubmit()">
      <!-- Form content -->
    </form>
  `,
})
export class MyFormComponent {
  private fb = inject(FormBuilder);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    amount: [null, [Validators.required, Validators.min(0)]],
    accountId: ['', Validators.required],
  });

  onSubmit(): void {
    if (this.form.valid) {
      const formData = this.form.getRawValue();
      // Process form data
    }
  }
}
```

## Mint Form Integration

Always use the Mint form components for consistent styling and accessibility.

```html
<form [mintForm]="form" (ngSubmit)="onSubmit()">
  <mint-form-section
    label="E-postadress"
    [control]="form.controls.email"
    errorMessage="Ange en giltig e-postadress">
    <mint-input formControlName="email" type="email" />
  </mint-form-section>

  <mint-form-section
    label="Belopp"
    [control]="form.controls.amount"
    description="Ange beloppet i kronor">
    <mint-input formControlName="amount" type="number" />
  </mint-form-section>

  <button mintButton type="submit" [disabled]="form.invalid">
    Skicka
  </button>
</form>
```

## Validation Patterns

### Built-in Validators

```typescript
form = this.fb.group({
  required: ['', Validators.required],
  minLength: ['', Validators.minLength(3)],
  maxLength: ['', Validators.maxLength(100)],
  min: [0, Validators.min(0)],
  max: [100, Validators.max(100)],
  pattern: ['', Validators.pattern(/^[A-Z]{2}\d{4}$/)],
  email: ['', Validators.email],
});
```

### Custom Validators

```typescript
export function positiveNumberValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value;
    if (value !== null && value <= 0) {
      return { positiveNumber: { value } };
    }
    return null;
  };
}

export function personnummerValidator(): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const value = control.value?.replace(/\D/g, '');
    if (value && value.length !== 12) {
      return { personnummer: { message: 'Personnumret måste vara 12 siffror' } };
    }
    return null;
  };
}
```

### Cross-Field Validation

```typescript
export function passwordMatchValidator(): ValidatorFn {
  return (group: AbstractControl): ValidationErrors | null => {
    const password = group.get('password')?.value;
    const confirmPassword = group.get('confirmPassword')?.value;

    if (password !== confirmPassword) {
      return { passwordMismatch: true };
    }
    return null;
  };
}
```

## Error Display Patterns

```typescript
private errorMessages: Record<string, string> = {
  required: 'Detta fält är obligatoriskt',
  email: 'Ange en giltig e-postadress',
  minlength: 'Värdet är för kort',
  maxlength: 'Värdet är för långt',
  min: 'Värdet är för lågt',
  max: 'Värdet är för högt',
  pattern: 'Ogiltigt format',
};

getErrorMessage(controlName: string): string {
  const control = this.form.get(controlName);
  if (!control?.errors) return '';

  const firstError = Object.keys(control.errors)[0];
  return this.errorMessages[firstError] ?? 'Ogiltigt värde';
}
```

## Form State Management

```typescript
hasChanges = computed(() => this.form.dirty);
isValid = computed(() => this.form.valid);
isSubmitting = signal(false);

async onSubmit(): Promise<void> {
  if (this.form.invalid) {
    this.form.markAllAsTouched();
    return;
  }

  this.isSubmitting.set(true);
  try {
    await this.submitForm(this.form.getRawValue());
  } finally {
    this.isSubmitting.set(false);
  }
}
```

## Dynamic Forms

```typescript
form = this.fb.group({
  items: this.fb.array([]),
});

get items(): FormArray {
  return this.form.get('items') as FormArray;
}

addItem(): void {
  this.items.push(this.fb.group({
    name: ['', Validators.required],
    quantity: [1, [Validators.required, Validators.min(1)]],
  }));
}

removeItem(index: number): void {
  this.items.removeAt(index);
}
```

## Best Practices

### ✅ DO

- **Use Reactive Forms** for complex validation scenarios
- **Integrate with Mint form components** for consistent styling
- **Show errors on blur or submit**, not while typing
- **Provide clear, Swedish error messages**
- **Disable submit button** only when form is submitting (not invalid)
- **Use `markAllAsTouched()`** before submission to show all errors
- **Validate on server** as well as client for security

### ❌ DON'T

- **Don't use disabled buttons** for invalid forms (accessibility issue)
- **Don't show errors immediately** on pristine fields
- **Don't use template-driven forms** for complex scenarios
- **Don't forget to handle async validation states**
- **Don't rely solely on client-side validation**

## Accessibility

- Always associate labels with inputs (Mint form section handles this)
- Use `aria-describedby` for error messages
- Ensure error messages are announced by screen readers
- Provide clear focus management after form submission
- Use `aria-invalid` on invalid fields
- For app-level form accessibility patterns, see [accessibility-app-level](/accessibility-app-level.md)
- For Mint component-level a11y, see [beta-mint-knowledge/accessibility](/../beta-mint-knowledge/accessibility.md)

## Related Documentation

- [Form component](/../beta-mint-components/references/form.md)
- [Input component](/../beta-mint-components/references/input.md)
- [Select component](/../beta-mint-components/references/select.md)
