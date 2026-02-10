# Migrating from KMP to Swift SDK

Guide for migrating from the Kotlin Multiplatform (KMP) account library to the pure Swift SDK.

## Overview

The PIAAccount Swift SDK (v2.0.0+) replaces the Kotlin Multiplatform implementation with a native Swift solution. This guide helps you migrate your iOS app from the KMP version to the new Swift package.

## Key Differences

### API Style

**KMP (v1.x)**: Callback-based API
```kotlin
accountAPI.loginWithCredentials(
    username = "user",
    password = "pass"
) { errors ->
    if (errors.isEmpty()) {
        // Success
    } else {
        // Handle errors
    }
}
```

**Swift (v2.0+)**: Async/await with callback wrappers
```swift
// Async/await (preferred)
Task {
    try await account.loginWithCredentials(username: "user", password: "pass")
}

// Callback (for compatibility)
account.loginWithCredentials(username: "user", password: "pass") { result in
    switch result {
    case .success: // Success
    case .failure(let error): // Handle error
    }
}
```

### Error Handling

**KMP (v1.x)**: List of errors in callback
```kotlin
{ errors: List<AccountRequestError> ->
    errors.forEach { error ->
        println("Error: ${error.code} - ${error.message}")
    }
}
```

**Swift (v2.0+)**: Swift Error throwing
```swift
do {
    try await account.loginWithCredentials(username: "user", password: "pass")
} catch let error as PIAAccountError {
    print("Error: \(error.code) - \(error.message ?? "")")
} catch let error as PIAMultipleErrors {
    for individualError in error.errors {
        print("Error: \(individualError.code)")
    }
}
```

### Return Values

**KMP (v1.x)**: Optional return in callback
```kotlin
fun accountDetails(callback: (details: AccountInformation?, errors: List<AccountRequestError>) -> Unit)
```

**Swift (v2.0+)**: Non-optional return, throws on error
```swift
func accountDetails() async throws -> AccountInformation
```

### Token Access

**KMP (v1.x)**: Function call
```kotlin
val token = accountAPI.apiToken()
```

**Swift (v2.0+)**: Property access
```swift
let token = account.apiToken
```

## Migration Steps

### 1. Update Dependencies

Remove KMP dependency from your `Podfile` or `Package.swift` and add the Swift package:

```swift
// Package.swift
dependencies: [
    // Remove:
    // .package(url: "path/to/kmp-account", from: "1.4.0"),

    // Add:
    .package(url: "https://github.com/pia-foss/account-sdk-ios", from: "2.0.0")
]
```

### 2. Update Imports

```swift
// Before (KMP)
import account

// After (Swift)
import PIAAccount
```

### 3. Update Client Initialization

**KMP (v1.x)**:
```kotlin
val accountAPI = Account(
    endpointProvider = MyEndpointProvider(),
    certificate = pemCertificate,
    userAgent = "MyApp/1.0"
)
```

**Swift (v2.0+)**:
```swift
let account = try PIAAccountBuilder()
    .setEndpointProvider(MyEndpointProvider())
    .setCertificate(pemCertificate)
    .setUserAgent("MyApp/1.0")
    .build()
```

### 4. Update Endpoint Provider

**KMP (v1.x)**:
```kotlin
class MyEndpointProvider : PIAAccountEndpointProvider {
    override fun accountEndpoints(): List<PIAAccountEndpoint> {
        return listOf(
            PIAAccountEndpoint(
                ipOrRootDomain = "privateinternetaccess.com",
                isProxy = false,
                usePinnedCertificate = true,
                certificateCommonName = "*.privateinternetaccess.com"
            )
        )
    }
}
```

**Swift (v2.0+)**:
```swift
struct MyEndpointProvider: PIAAccountEndpointProvider {
    func accountEndpoints() -> [PIAAccountEndpoint] {
        return [
            PIAAccountEndpoint(
                ipOrRootDomain: "privateinternetaccess.com",
                isProxy: false,
                usePinnedCertificate: true,
                certificateCommonName: "*.privateinternetaccess.com"
            )
        ]
    }
}
```

### 5. Update API Calls

#### Login

**KMP (v1.x)**:
```kotlin
accountAPI.loginWithCredentials("user", "pass") { errors ->
    if (errors.isEmpty()) {
        // Success
    } else {
        // Handle errors
    }
}
```

**Swift (v2.0+)**:
```swift
Task {
    do {
        try await account.loginWithCredentials(username: "user", password: "pass")
        // Success
    } catch {
        // Handle error
    }
}

// Or with callbacks:
account.loginWithCredentials(username: "user", password: "pass") { result in
    switch result {
    case .success: // Success
    case .failure(let error): // Handle error
    }
}
```

#### Account Details

**KMP (v1.x)**:
```kotlin
accountAPI.accountDetails { details, errors ->
    if (details != null) {
        println("Plan: ${details.plan}")
    } else {
        // Handle errors
    }
}
```

**Swift (v2.0+)**:
```swift
Task {
    do {
        let details = try await account.accountDetails()
        print("Plan: \(details.plan)")
    } catch {
        // Handle error
    }
}
```

#### Logout

**KMP (v1.x)**:
```kotlin
accountAPI.logout { errors ->
    // Always clears tokens, even if server request fails
}
```

**Swift (v2.0+)**:
```swift
Task {
    try? await account.logout()
    // Always clears tokens, even if throws
}
```

## Feature Parity

### Included Features

All iOS-specific features from KMP v1.x are preserved:

- ✅ Username/password authentication
- ✅ App Store receipt authentication
- ✅ Email login links
- ✅ Token migration
- ✅ Account details and deletion
- ✅ Email management
- ✅ iOS subscriptions
- ✅ iOS payment information
- ✅ Dedicated IPs
- ✅ Invites/referrals
- ✅ Gift card redemption
- ✅ Feature flags
- ✅ In-app messages
- ✅ Certificate pinning
- ✅ Token auto-refresh (21-day threshold)
- ✅ Multi-endpoint failover

### Excluded Features

Android-specific features are not included:

- ❌ Google Play receipt authentication
- ❌ Amazon App Store integration
- ❌ Android-specific payment methods

## Common Migration Patterns

### Converting Callback to Async/Await

If you have callback-based code:

**Before**:
```kotlin
fun fetchAccountDetails(completion: (AccountInformation?) -> Unit) {
    accountAPI.accountDetails { details, errors ->
        completion(details)
    }
}
```

**After**:
```swift
func fetchAccountDetails() async throws -> AccountInformation {
    return try await account.accountDetails()
}

// Call site:
Task {
    do {
        let details = try await fetchAccountDetails()
        // Use details
    } catch {
        // Handle error
    }
}
```

### Maintaining Callback Style

If you need to keep callbacks (e.g., for UIKit code):

```swift
func fetchAccountDetails(completion: @escaping (Result<AccountInformation, Error>) -> Void) {
    account.accountDetails(completion: completion)
}

// Usage:
fetchAccountDetails { result in
    switch result {
    case .success(let details):
        // Use details
    case .failure(let error):
        // Handle error
    }
}
```

### Error Handling

**Before (KMP)**:
```kotlin
accountAPI.accountDetails { details, errors ->
    errors.forEach { error ->
        when (error.code) {
            401 -> // Unauthorized
            500 -> // Server error
            else -> // Other errors
        }
    }
}
```

**After (Swift)**:
```swift
do {
    let details = try await account.accountDetails()
} catch let error as PIAAccountError {
    switch error.code {
    case 401: // Unauthorized
    case 500: // Server error
    default: // Other errors
    }
} catch let error as PIAMultipleErrors {
    // Handle multiple endpoint failures
    for individualError in error.errors {
        print("Endpoint error: \(individualError.code)")
    }
}
```

### Token Storage

Both versions use iOS Keychain, but access patterns differ:

**KMP (v1.x)**:
```kotlin
val token = accountAPI.apiToken() // Function call
```

**Swift (v2.0+)**:
```swift
let token = account.apiToken // Property access (thread-safe)
```

## Testing Your Migration

### Checklist

- [ ] Remove KMP dependency
- [ ] Add Swift package
- [ ] Update imports
- [ ] Migrate initialization code
- [ ] Convert all API calls
- [ ] Update error handling
- [ ] Test authentication flow
- [ ] Verify token storage
- [ ] Test account operations
- [ ] Validate subscription handling
- [ ] Test certificate pinning (if used)
- [ ] Verify logout clears tokens

### Validation

Test these critical flows:

1. **Login Flow**: Credentials → Success → Token cached
2. **Receipt Login**: App Store receipt → Authentication
3. **Account Details**: Fetch → Parse → Display
4. **Token Refresh**: Wait 21 days or mock → Auto-refresh
5. **Logout**: Clear tokens → Verify nil
6. **Error Handling**: Invalid credentials → Proper error

## Breaking Changes

### Version 2.0.0

- **Package Name**: `account` → `PIAAccount`
- **API Style**: Callbacks → Async/await (with callback wrappers)
- **Error Handling**: List in callback → Swift Error throwing
- **Return Values**: Optional → Non-optional with throws
- **Token Access**: Function → Property
- **Builder**: Direct init → Fluent builder pattern

## Need Help?

If you encounter issues during migration:

1. Check the full API reference: ``PIAAccountAPI``
2. Review error codes: ``PIAAccountError``
3. See working examples in <doc:GettingStarted>
4. Open an issue on GitHub

## See Also

- ``PIAAccountAPI``
- ``PIAAccountBuilder``
- ``PIAAccountError``
- <doc:GettingStarted>
