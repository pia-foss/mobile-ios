# PIAAccessibility

Swift Package containing every accessibility identifier the PIA VPN apps set and the UI tests query.

## Overview

This package is the single source of truth for accessibility identifiers, per
[ADR-0015](../../ADRs/0015-accessibility-identifiers-package.md). Views set identifiers from
`AccessibilityID`, and the UI tests find elements through the same constants, so the two cannot
drift apart.

No other module declares identifiers: no `<Feature>Accessibility` enums in feature packages, no
identifier files in the app target, and no identifier string literals in views or tests.

The package has **no dependencies** and must stay that way. The UI test bundles link it, and they
must not pull in the app's modules.

## Usage

Import the module wherever an identifier is set or queried.

SwiftUI:

```swift
import PIAAccessibility

Button(L10n.Login.submit, action: logIn)
    .accessibilityIdentifier(AccessibilityID.Login.submit)
```

UIKit:

```swift
import PIAAccessibility

navigationItem.leftBarButtonItem?.accessibilityIdentifier = AccessibilityID.Dashboard.menu
```

UI tests (`PIA-VPN_E2E_Tests`):

```swift
import PIAAccessibility

var loginButton: XCUIElement { button(with: AccessibilityID.Login.submit) }
```

## Adding an identifier

1. Add a `public static let` to the screen's namespace in
   `Sources/PIAAccessibility/AccessibilityID.swift`. If the screen has no namespace yet, add a
   `public enum` named after the screen, keeping the namespaces in alphabetical order.
2. Name the member after the element's role (`submit`, `close`, `email`), matching the style of the
   members already in that namespace.
3. Give it the value `id.<screen>.<element>`: the namespace in lowerCamelCase, then the member name.
   `AccessibilityID.AddEmail.submit` → `"id.addEmail.submit"`.
4. Check the value is not already used anywhere in the file. Values must be unique across all
   screens, not just within one.
5. Use the constant in the view and in the test. Never repeat the string.

For an identifier that depends on runtime data, add a `static func` that builds it, as
`DebugReport.section(_:)` does.

## Using it from a new module

- **Feature package:** add `.package(path: "../PIAAccessibility")` to the package dependencies and
  `.product(name: "PIAAccessibility", package: "PIAAccessibility")` to the target that sets
  identifiers.
- **Xcode target** (app or UI test bundle): add `PIAAccessibility` to the target's
  `package-product-members` in `PIA VPN.xcodeproj/project.xcproj`, as `PIA VPN` and
  `PIA-VPN_E2E_Tests` do.

## Rules

- Every identifier is declared here, exactly once.
- Never reuse a value for two elements, even on different screens.
- Keep existing values unchanged unless you update every test that uses them in the same change.
  Older identifiers keep historical spellings (`ForceUpdateScreen`, `uitests.regions.region_name`)
  so automation outside this repository keeps working.
- Do not use localized text as an identifier, and do not build identifiers from enum case names
  (`"id.menu.\(self)"`). Map each case to an explicit constant, as `MenuViewController.Item` does.
- When a cell is reused, give every row an identifier, so a reused cell never keeps the previous
  row's identifier.
