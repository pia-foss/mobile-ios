# 0002: iOS In-App Message System

Date: 2026-03-13

## Context

The iOS app needs a way to display informational messages to users on the dashboard — locally generated system alerts (e.g., Dedicated IP token expiring).

A tile-based messaging system was built to serve this purpose. It renders messages as a tile in section 0 ("fixed tiles") of the dashboard `UICollectionView`, supporting multiple message types with different actions.

## Current State

The system handles three types of system messages:

- Dedicated IP token expiring (`PIADIPRegionExpiring` notification)
- Dedicated IP address changed (`PIADIPCheckIP` notification)
- In-app survey prompt (`showInAppSurveyMessage()`)

Messages are created locally and posted via `MessagesManager.shared.postSystemMessage(message:)`.

## Architecture

### Message Flow

```
Message created
  -> MessagesManager.shared.postSystemMessage(message:)
    -> Posts .PIAUpdateFixedTiles notification
      -> DashboardViewController reloads section 0
        -> MessagesTile renders the message
```

### Data Model

`InAppMessage` (`PIALibrary`):

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique ID for dismiss tracking |
| `message` | `[String: String]` | Localized message text (required) |
| `linkMessage` | `[String: String]?` | Localized CTA/link text |
| `type` | `InAppMessageType` | `.none`, `.action`, `.view`, `.link` |
| `level` | `InAppMessageLevel` | `.system` (orange) |
| `settingAction` | `[String: Bool]?` | For `.action` type: settings to toggle |
| `settingView` | `String?` | For `.view` type: screen to navigate to |
| `settingLink` | `String?` | For `.link` type: URL to open |

Localized text dictionaries use locale fallback: exact match -> language-only -> prefix match -> `"en-US"`.

### Message Types & Commands

| Type | Command | Behavior |
|------|---------|----------|
| `.link` | `LinkCommand` | Opens a URL |
| `.view` | `ViewCommand` | Navigates to an internal screen (`settings`, `regions`, `account`, `dip`, `about`) |
| `.action` | `ActionCommand` | Executes settings changes (killswitch, NMT, VPN protocol, geolocation) |
| `.none` | — | Informational only, no action |

### Message Priority

Only one message displays at a time. Priority order (highest first):
1. Update message
2. System message

If a message is available, it replaces the feedback/rating tile in the fixed tile slot.

### Display

- Messages render as a tile in the dashboard `UICollectionView` section 0
- The tile shows an orange alert icon, message text, and a dismiss button
- A separate SwiftEntryKit-based banner system (`Macros+UI.swift`) is used for transient toast notifications after action commands, but is not part of the message tile display

## Key Files

| File | Path |
|------|------|
| **MessagesManager** | `PIA VPN/Core/Messages/MessagesManager.swift` |
| **MessagesCommands** | `PIA VPN/Core/Messages/MessagesCommands.swift` |
| **InAppMessage model** | `LocalPackages/PIALibrary/Sources/PIALibrary/WebServices/InAppMessage.swift` |
| **MessagesTile** | `PIA VPN/Core/Tiles/MessagesTile.swift` |
| **MessagesTile XIB** | `PIA VPN/Core/Tiles/MessagesTile.xib` |
| **DashboardViewController** | `PIA VPN/UI/Dashboard/DashboardViewController.swift` |

## Consequences

- New system messages can be posted immediately by calling `MessagesManager.shared.postSystemMessage(message:)` — the UI infrastructure is fully wired up.
