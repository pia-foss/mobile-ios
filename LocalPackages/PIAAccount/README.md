# PIA Account

A Swift Package Manager library for Private Internet Access account management.

## Overview

PIAAccount provides a native Swift implementation for managing PIA accounts, subscriptions, authentication, and more. This library replaces the previous Kotlin Multiplatform implementation with modern Swift async/await APIs and zero external dependencies.

## Features

- **Authentication**: Login with credentials, App Store receipts, or email links
- **Account Management**: Retrieve account details, manage subscriptions, handle dedicated IPs
- **Security**: Native certificate pinning and Keychain storage for tokens
- **Modern APIs**: Async/await with callback wrappers for backward compatibility
- **Zero Dependencies**: Pure Swift using Foundation and Security frameworks

## Requirements

- iOS 15.0+
- macOS 12.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/PIAAccount.git", from: "2.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version 2.0.0 or later

## Usage

### Building an Account Client

```swift
import PIAAccount

let account = try PIAAccountBuilder()
    .setEndpointProvider(myEndpointProvider)
    .setCertificate(pinnedCertificate)
    .setUserAgent("MyApp/1.0")
    .build()
```

### Async/Await API (Preferred)

```swift
// Login with credentials
try await account.loginWithCredentials(
    username: "myusername",
    password: "mypassword"
)

// Get account details
let details = try await account.accountDetails()
print("Plan: \(details.plan)")

// Logout
try await account.logout()
```

### Callback API (Backward Compatibility)

```swift
// Login with callbacks
account.loginWithCredentials(username: "myusername", password: "mypassword") { result in
    switch result {
    case .success:
        print("Login successful")
    case .failure(let error):
        print("Login failed: \(error)")
    }
}

// Get account details with callback
account.accountDetails { result in
    switch result {
    case .success(let details):
        print("Plan: \(details.plan)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Token Access

```swift
// Synchronous token access
if let apiToken = account.apiToken {
    print("API Token: \(apiToken)")
}

if let vpnToken = account.vpnToken {
    print("VPN Token: \(vpnToken)")
}
```

## API Coverage

- Authentication: `loginWithCredentials`, `loginWithReceipt`, `loginLink`, `logout`
- Account: `accountDetails`, `deleteAccount`, `clientStatus`
- Dedicated IPs: `dedicatedIPs`, `renewDedicatedIP`
- Subscriptions: `subscriptions` (App Store)
- Email: `setEmail`
- Payment: `payment` (iOS-specific)
- Sign up: `signUp`
- Social: `sendInvite`, `invitesDetails`
- Promotions: `redeem`
- Features: `message`, `featureFlags`

## Migration from KMP

This library replaces the Kotlin Multiplatform `cpz_pia-mobile_shared_account` library. Key differences:

- **Async/await**: Replace callbacks with async/await (or use callback wrappers)
- **Error handling**: Errors are thrown instead of passed to callbacks
- **Return types**: Non-optional return values (throws on error instead)
- **Versioning**: v2.0.0+ (breaking change from KMP v1.x)

See the [Migration Guide](docs/Migration.md) for detailed migration instructions.

## Security

- **Certificate Pinning**: Optional SSL certificate pinning for enhanced security
- **Keychain Storage**: Tokens are securely stored in iOS Keychain
- **Token Auto-Refresh**: Automatic token refresh when expiration < 21 days

## License

Copyright © 2025 Private Internet Access. All rights reserved.

## Version

Current version: **2.0.0**
