# 0015: Accessibility identifiers live in one package

Date: 2026-11-26

## Context

UI tests find elements by accessibility identifier, so the app and the tests must agree on every
value. Until this change the same identifier was declared in up to four places:

- `Accessibility.Id` in the app, used by UIKit screens.
- `PIALibraryAccessibility.Id` and `AccessibilityId` in a second app file, compiled into the E2E
  target through a target-membership exception.
- One `<Feature>Accessibility` enum per feature package (`LoginAccessibility`,
  `PaywallAccessibility`, …), because packages cannot see app files.
- String literals in views and E2E screens.

Comments ("must match `Accessibility.Id.Login`") were the only thing keeping the copies in sync, and
they drifted: the login password field carried the submit button's identifier in three files, the
paywall's Log In button reused `id.login.submit`, and menu cells only set an identifier on some
rows, so a reused cell could keep a stale one.

## Decision

All accessibility identifiers live in `AccessibilityID`, in the
[`LocalPackages/PIAAccessibility`](../LocalPackages/PIAAccessibility/README.md) package. It follows
the shared-infrastructure pattern of ADR-0003 (`PIAAssets`, `PIALocalizations`).

### Where identifiers live

- `AccessibilityID` in `Sources/PIAAccessibility/AccessibilityID.swift` is the only place an
  identifier is declared.
- Feature packages, the iOS app and the E2E test target depend on `PIAAccessibility`. Views set
  identifiers from it and tests query elements through it.
- The package has **no dependencies**, so a UI test bundle can link it without pulling in the app's
  modules. Keep it that way.

### Convention

- **Structure:** one caseless `public enum` per screen, nested in `AccessibilityID`, in alphabetical
  order. Each identifier is a `public static let`: `AccessibilityID.Login.submit`.
- **Member names** describe the element's role (`submit`, `close`, `email`) and match the style of
  the namespace they join.
- **Values** for new identifiers are `id.<screen>.<element>`: the namespace in lowerCamelCase, then
  the member name. `AccessibilityID.AddEmail.submit` → `"id.addEmail.submit"`.
- **Unique:** a value is never used for two elements, even on different screens.
- **Runtime data:** an identifier built from runtime data is a `static func` in the namespace
  (`AccessibilityID.DebugReport.section(_:)`).
- **Existing values** kept their spelling when they moved (`ForceUpdateScreen`,
  `uitests.regions.region_name`), so automation outside this repository keeps working. Change one
  only together with every test that reads it.

### What is not allowed

- A `<Feature>Accessibility` enum, or any other identifier declaration, outside `PIAAccessibility`.
- Identifier string literals in views or tests, including `XCUIElement` queries and predicates.
- Identifiers built from enum case names (`"id.menu.\(self)"`). Map each case to an explicit
  constant with an exhaustive `switch`, as `MenuViewController.Item.accessibilityIdentifier` does.
- Localized text used as an identifier.
- Setting an identifier on only some rows of a reused cell. Every row gets one, so a reused cell
  never keeps the previous row's identifier.

### Checklist when adding a screen or element

1. Add the constant to the screen's namespace in `AccessibilityID.swift`, creating the namespace if
   needed.
2. Make sure the feature package depends on `PIAAccessibility` (see the package README for the
   manifest lines) and imports it.
3. Set the identifier in the view from the constant.
4. In the E2E screen file, `import PIAAccessibility` and query the element through the same constant.
5. Check no value is duplicated:
   `grep -o '"[^"]*"' LocalPackages/PIAAccessibility/Sources/PIAAccessibility/AccessibilityID.swift | sort | uniq -d`
   prints nothing.

## Consequences

- Changing an identifier is a one-line change that the views and the tests pick up together.
- Adding one means editing `PIAAccessibility` as well as the feature, which is the point: the
  identifier becomes visible to the tests.
- Feature packages are slightly less self-contained than ADR-0003 describes: they all depend on this
  one shared package. That is the same trade-off already made for strings and assets.
- `AccessibilityID.swift` is a file many changes touch. If merge conflicts become frequent, split it
  into one file per namespace inside the package without changing the API.
- Identifiers derived from runtime content (for example, a card's localized CTA title in
  `PIACardsViewController`) are not identifiers in this sense and stay where they are until that
  screen is rewritten.
