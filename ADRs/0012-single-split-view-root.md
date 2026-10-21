# 0012: One split-view root on every iOS device

Date: 2026-10-16

## Context

The logged-in UI was built two ways:

- **iPad and Mac Catalyst** used `AdaptiveSplitViewController`, with `MenuViewController` as the
  sidebar column and the dashboard navigation controller as the secondary column. Login was a window
  root swap through `RootCoordinator.setRoot(.login)`.
- **iPhone** used a bare `UINavigationController(Dashboard)` as the root, with the `SideMenu`
  package presenting `MenuViewController` modally as a drawer. Login was a `SignupCoordinator`
  that `DashboardViewController` presented modally over itself.

So `RootCoordinator`, `DashboardViewController` and `MenuViewController` each branched on idiom.
There were two signup coordinators with different owners, which forced
`RootCoordinator.activeSignupCoordinator` to be a weak pointer that followed whichever one was on
screen, so that the magic-link deep link could reach it. iPhone also carried a third-party
dependency for a single screen.

## Decision

### Every device gets the split view

`RootCoordinator.makeMainRoot()` always builds the `AdaptiveSplitViewController`.

- On iPhone, in every orientation, the sidebar is a hidden `.overlay`. The dashboard menu button
  (the split's own `show(.primary)` / `hide(.primary)`) and the system edge swipe open it, as with
  the old drawer.
- On iPad and Mac the existing 700pt width threshold still applies: overlay below it, tiled
  beside the dashboard at or above it.

On iPhone the overlay is the system one: its dimming, column width and gestures replace SideMenu's
custom slide-in styling.

### `SidebarRootViewController` keeps the split from collapsing

In a compact horizontal size class, `UISplitViewController` collapses into a single navigation
stack and never shows an overlay. The window root is therefore `SidebarRootViewController`, which
embeds the split:

- On iPhone it forces a **regular** horizontal size class on the split.
- It pushes the window's **real** size class back onto both columns. Without that, screens that
  read it, such as `ModalNavigationSegue` choosing a form sheet over full screen, would change
  their layout and presentation.

It uses `traitOverrides` on iOS 17+ and `setOverrideTraitCollection(_:forChild:)` before that.
Before iOS 17 a view controller cannot override its own traits, only a parent can, so the
container stays while the minimum is iOS 15. Once the minimum is iOS 17, the overrides can move
into `AdaptiveSplitViewController` and the container can go.
Modals the dashboard presents are hosted by this container, which keeps the real traits.

### Login is a root swap everywhere

`DashboardViewController.presentLogin()` always calls `RootCoordinator.setRoot(.login)`.
`RootCoordinator` owns the only `SignupCoordinator`: it exposes it read-only for the magic link and
releases it when the root returns to `.main`. On iPhone, logout now swaps the root instantly rather
than animating a modal.

### SideMenu is removed

The package is removed, along with its `SideMenuNavigationController` storyboard class, the
`MenuSegueIdentifier` segue, `Theme.applySideMenu()` and the license entries.

## Consequences

### Positive

- One code path for the main UI and one for login on iPhone, iPad and Mac.
- `RootCoordinator` holds the signup flow strongly and exclusively; the weak "active" pointer is gone.
- When a menu item is chosen from the overlay sidebar, the overlay closes. That matches the old
  iPhone drawer, and now applies to narrow iPad and Mac windows too.
- One fewer third-party dependency.

### Negative

- `SidebarRootViewController` relies on overriding traits around a system container. A UIKit change
  to how `UISplitViewController` propagates traits to its columns would show up here first.
