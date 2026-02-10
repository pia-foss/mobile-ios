# Getting Started with PIAAccount

Learn how to integrate and use the PIAAccount SDK in your iOS application.

## Overview

This guide walks you through installing the PIAAccount SDK, configuring your first client, and performing common account operations like login and retrieving account details.

## Installation

### Swift Package Manager

Add PIAAccount to your project using Swift Package Manager:

1. In Xcode, select **File → Add Package Dependencies...**
2. Enter the repository URL or add the local package
3. Select the version or branch you want to use
4. Add `PIAAccount` to your target

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/pia-foss/account-sdk-ios", from: "2.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["PIAAccount"]
    )
]
```

## Basic Setup

### 1. Create an Endpoint Provider

First, implement `PIAAccountEndpointProvider` to configure API endpoints:

```swift
import PIAAccount

struct MyEndpointProvider: PIAAccountEndpointProvider {
    func accountEndpoints() -> [PIAAccountEndpoint] {
        return [
            // Primary endpoint
            PIAAccountEndpoint(
                ipOrRootDomain: "privateinternetaccess.com",
                isProxy: false,
                usePinnedCertificate: true,
                certificateCommonName: "*.privateinternetaccess.com"
            ),
            // Fallback endpoint (optional)
            PIAAccountEndpoint(
                ipOrRootDomain: "10.0.0.1",
                isProxy: false,
                usePinnedCertificate: false,
                certificateCommonName: nil
            )
        ]
    }
}
```

### 2. Build the Client

Use `PIAAccountBuilder` to create an account client:

```swift
do {
    let account = try PIAAccountBuilder()
        .setEndpointProvider(MyEndpointProvider())
        .setCertificate(pemCertificateString) // Optional: for certificate pinning
        .setUserAgent("MyApp/1.0")
        .build()

    // Store account client for later use
    self.accountClient = account
} catch {
    print("Failed to build account client: \(error)")
}
```

## Authentication

### Login with Credentials

```swift
Task {
    do {
        try await account.loginWithCredentials(
            username: "your-username",
            password: "your-password"
        )
        print("Login successful!")

        // Tokens are now cached and accessible
        if let apiToken = account.apiToken {
            print("API Token: \(apiToken)")
        }
    } catch let error as PIAAccountError {
        switch error.code {
        case 401:
            print("Invalid credentials")
        default:
            print("Login failed: \(error.errorDescription ?? "Unknown error")")
        }
    }
}
```

### Login with App Store Receipt (iOS)

For users who purchased through the App Store:

```swift
// Get the App Store receipt
guard let receiptURL = Bundle.main.appStoreReceiptURL,
      let receiptData = try? Data(contentsOf: receiptURL) else {
    print("No receipt found")
    return
}

let receiptBase64 = receiptData.base64EncodedString()

Task {
    do {
        try await account.loginWithReceipt(receiptBase64: receiptBase64)
        print("Receipt login successful!")
    } catch {
        print("Receipt login failed: \(error)")
    }
}
```

### Using Callbacks (Alternative)

If you prefer callbacks or need to support pre-async/await code:

```swift
account.loginWithCredentials(username: "user", password: "pass") { result in
    switch result {
    case .success:
        print("Login successful!")
    case .failure(let error):
        print("Login failed: \(error)")
    }
}
```

## Retrieving Account Details

After successful login, fetch account information:

```swift
Task {
    do {
        let details = try await account.accountDetails()

        print("Username: \(details.username)")
        print("Email: \(details.email)")
        print("Plan: \(details.plan)")
        print("Days Remaining: \(details.daysRemaining)")
        print("Active: \(details.active)")
        print("Expired: \(details.expired)")
    } catch {
        print("Failed to get account details: \(error)")
    }
}
```

## Token Management

### Accessing Cached Tokens

Tokens are automatically cached for synchronous access:

```swift
// Synchronous access (thread-safe)
if let apiToken = account.apiToken {
    print("API Token: \(apiToken)")
}

if let vpnToken = account.vpnToken {
    print("VPN Token: \(vpnToken)")
    // Use this token for VPN server authentication
}
```

### Automatic Token Refresh

Tokens are automatically refreshed when they expire within 21 days. You don't need to manually check or refresh tokens - the SDK handles this transparently before each API request.

## Logout

Clear stored tokens and logout:

```swift
Task {
    do {
        try await account.logout()
        print("Logged out successfully")

        // Tokens are now cleared
        assert(account.apiToken == nil)
        assert(account.vpnToken == nil)
    } catch {
        print("Logout failed: \(error)")
    }
}
```

## Error Handling

All SDK methods can throw `PIAAccountError`:

```swift
Task {
    do {
        try await account.loginWithCredentials(username: "user", password: "pass")
    } catch let error as PIAAccountError {
        print("Error Code: \(error.code)")
        print("Message: \(error.message ?? "No message")")
        print("Description: \(error.errorDescription ?? "Unknown")")

        // Handle specific errors
        switch error.code {
        case 401:
            // Unauthorized - invalid credentials
            showLoginError()
        case 429:
            // Too many requests - show retry timer
            if error.retryAfterSeconds > 0 {
                showRetryTimer(seconds: error.retryAfterSeconds)
            }
        case 500...599:
            // Server error
            showServerError()
        case 600...:
            // Network error
            checkNetworkConnection()
        default:
            showGenericError()
        }
    } catch let error as PIAMultipleErrors {
        // Multiple endpoints failed
        print("All endpoints failed: \(error.errors.count) errors")
        for individualError in error.errors {
            print("  - [\(individualError.code)]: \(individualError.message ?? "No message")")
        }
    }
}
```

## Common Patterns

### Check if Logged In

```swift
func isLoggedIn() -> Bool {
    return account.apiToken != nil
}
```

### Conditional API Calls

```swift
guard account.apiToken != nil else {
    print("Not logged in")
    return
}

// Proceed with authenticated request
let details = try await account.accountDetails()
```

### Handle Session Expiry

```swift
do {
    let details = try await account.accountDetails()
    // Success
} catch let error as PIAAccountError where error.code == 401 {
    // Session expired - prompt for re-login
    showLoginScreen()
}
```

## Next Steps

- Explore the full API reference in ``PIAAccountAPI``
- Learn about migrating from KMP in <doc:Migration>
- Review security best practices (certificate pinning, token storage)
- Implement subscription management for iOS App Store purchases
- Add dedicated IP management for users with DIP tokens

## See Also

- ``PIAAccountBuilder``
- ``PIAAccountAPI``
- ``PIAAccountError``
- ``AccountInformation``
