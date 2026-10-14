# 0012: Review CSI debug reports before sending

Date: 2026-10-13

## Context

When a user submits debug logs from **Settings → Help → "Send Debug Log to support"**, the app
collects a set of CSI sections, joins them into a single report, and uploads it. Until this change
the collection and the upload were the same operation (`PIAWebServices+Ephemeral.submitDebugReport`)
and the row sent immediately: the user had no way to see what was about to leave the device.

The desktop client already solves this. Its support tool
(`pia-desktop-qt/extras/support-tool`) opens a window that lists the exact payload contents, lets the
user toggle whole categories ("Include technical debug logs", "Include crash reports"), offers a
"Save as Zip", and only then submits. The iOS flow had no equivalent.

This is a privacy and support-quality gap, not just a UI nicety: the report can contain logs and
network details, and support quality improves when users can confirm what they are sending.

`submitDebugReport` also fused two responsibilities that are useful independently — *building* the
report (domain, testable) and *sending* it (transport). Splitting them is what makes a preview
truthful: the reviewed text can be the submitted text, byte for byte.

## Decision

### Split building from submitting in `PIALibrary`

Introduce a value type and a builder that own report assembly, with no networking:

- `DebugReport` — the assembled report: ordered `Section`s (each with a `SectionKind`), a `text`
  computed in the existing CSI format, and kind filtering.
- `DebugReportBuilder` — owns the provider list, tags each section's kind
  (`application.log` → `.debugLog`, `tunnel.log`/`last_tunnel.log` → `.tunnelLog`, everything else
  `.mandatory`), performs the live-vs-persisted tunnel-log selection, and exposes a pure `assemble`.

`PIAWebServices` keeps the transport and gains `buildDebugReport(...)` and `submit(report:)`;
`submitDebugReport(...)` becomes `build → submit`. `Client` exposes matching public entry points.
The review screen submits the **already-built** report (`Client.submitDebugReport(_ report:)`) so
what was previewed is exactly what is sent.

### A dedicated feature module, following the existing architecture

A new Swift package `LocalPackages/PIADebugReport` implements the screen as a hand-rolled
unidirectional (MVI) feature over `apple-core` `CoreArchitecture`, matching `PIAAbout`,
`PIADedicatedIP`, `PIAPaywall` and `PIAValidateQRLogin` (see ADR 0009):

- `DebugReportReview` namespace (`State` / `Action` / `Dependencies` / `Output` / `Failure`),
  a pure `Reducer`, a `Store`, and `+Live` wired by the host.
- The reducer never reaches for `Client`; the host supplies `buildReport` / `submitReport` closures
  and handles `Output`s (ADR 0009's dependency seam).
- A `ViewWithTitle` SwiftUI view shows the privacy note, the section list (expandable, monospaced,
  preview-capped), a redaction note, a "Save report" share action, and Send.

Presentation is orchestrated by a `ModalCoordinator` in the app (`DebugReportCoordinator`,
ADR 0007); `HelpSettingsViewController` starts it instead of sending immediately.

### Parity with the desktop support tool

- **All or nothing**: unlike the desktop tool, there are no category toggles. Every section shown,
  including the debug and tunnel logs, is sent; the user's choice is to send the report or not.
  Support always receives a complete report, and the screen stays a single review-and-confirm step.
- **Redaction is always on** for the user flow and is disclosed, not toggleable.
- **"Save report"** shares the exact report text, the iOS analog of "Save as Zip".

User-facing strings live in `PIALocalizations`, like every other feature package (ADR 0003).

## Consequences

### Positive

- **WYSIWYG submissions.** The report is built once and submitted as reviewed, so the preview cannot
  drift from what is sent.
- **Testable assembly.** `DebugReportBuilder.assemble` is pure and unit-tested independently of the
  network and the UI; the screen's behaviour is covered with `TestStore`.
- **Close to desktop parity.** Users can review and save the exact payload, as on desktop, without
  being able to strip the logs support needs.
- **Reusable and shareable.** Assembly lives in `PIALibrary` and the screen has no iOS-only
  assumptions, so tvOS can adopt the same flow without reimplementing the report (ADR 0003).
- **Follows the established architecture.** No new patterns: MVI feature package, coordinator
  hosting, dependency seam, shared strings.

### Neutral

- **No partial reports.** A user who objects to a section can only decline to send. This is
  deliberate: a report missing its logs is rarely actionable.
- **An extra step before sending.** Submitting is now review → send instead of a single tap. This is
  the intended trade-off.
- **`submitDebugReport` remains** as a build-then-submit convenience for callers that do not need a
  preview (e.g. the internal debug menu).

### Negative

- **Section metadata must be maintained.** Adding a provider to `DebugReportBuilder.build` requires
  choosing a `SectionKind`, and the review screen needs a display name for its CSI section name (it
  falls back to the raw name).
- **One more module to keep current.** The screen owns a small amount of UI and its own tests.

## References

- [ADR 0006](0006-replace-csi-sdk-with-internal-implementation.md) — the internal CSI implementation this amends
- [ADR 0003](0003-swiftui-feature-modules-as-swift-packages.md) — SwiftUI feature modules as Swift packages
- [ADR 0009](0009-unidirectional-mvi-architecture.md) — unidirectional (MVI) architecture
- [ADR 0007](0007-ios-coordinator-navigation-pattern.md) — coordinator navigation
- `LocalPackages/PIALibrary/Sources/PIALibrary/DebugReport/` — `DebugReport`, `DebugReportBuilder`
- `LocalPackages/PIADebugReport/` — the review feature module
- `PIA VPN/UI/Help/DebugReportCoordinator.swift` — host wiring
- `pia-desktop-qt/extras/support-tool` — the desktop support tool this mirrors
