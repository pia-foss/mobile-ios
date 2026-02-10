# ``PIAAccount``

Pure Swift SDK for Private Internet Access account management on iOS.

## Overview

PIAAccount is a modern Swift package providing comprehensive account management for Private Internet Access (PIA) VPN services. Built with Swift's async/await concurrency model, it offers both modern async APIs and traditional callback-based interfaces for maximum compatibility.

### Key Features

- **Modern Async/Await APIs**: All operations support Swift's native async/await pattern
- **Callback Compatibility**: Optional callback wrappers for UIKit and legacy code
- **Secure Token Storage**: Automatic Keychain integration with thread-safe access
- **Auto Token Refresh**: Tokens automatically refresh when expiring within 21 days
- **Certificate Pinning**: Built-in SSL/TLS certificate pinning for enhanced security
- **Multi-Endpoint Failover**: Automatic retry across multiple endpoints
- **Zero Dependencies**: Pure Swift implementation with no external dependencies

### Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Topics

### Getting Started

- <doc:GettingStarted>
- <doc:Migration>

### Building the Client

- ``PIAAccountBuilder``
- ``PIAAccountEndpointProvider``
- ``PIAAccountEndpoint``

### Core API

- ``PIAAccountAPI``
- ``PIAAccountClient``

### Authentication

- ``PIAAccountAPI/loginWithCredentials(username:password:)``
- ``PIAAccountAPI/loginWithReceipt(receiptBase64:)``
- ``PIAAccountAPI/loginLink(email:)``
- ``PIAAccountAPI/migrateApiToken(apiToken:)``
- ``PIAAccountAPI/logout()``

### Account Management

- ``PIAAccountAPI/accountDetails()``
- ``PIAAccountAPI/deleteAccount()``
- ``PIAAccountAPI/clientStatus()``
- ``AccountInformation``
- ``ClientStatusInformation``

### Subscriptions & Payment

- ``PIAAccountAPI/subscriptions(receipt:)``
- ``PIAAccountAPI/payment(username:password:information:)``
- ``PIAAccountAPI/signUp(information:)``
- ``IOSSubscriptionInformation``
- ``IOSPaymentInformation``
- ``IOSSignupInformation``
- ``SignUpInformation``

### Dedicated IPs

- ``PIAAccountAPI/dedicatedIPs(ipTokens:)``
- ``PIAAccountAPI/renewDedicatedIP(ipToken:)``
- ``DedicatedIPInformation``

### Social & Promotions

- ``PIAAccountAPI/sendInvite(email:name:)``
- ``PIAAccountAPI/invitesDetails()``
- ``PIAAccountAPI/redeem(email:code:)``
- ``InvitesDetailsInformation``
- ``RedeemInformation``

### Feature Management

- ``PIAAccountAPI/message(appVersion:)``
- ``PIAAccountAPI/featureFlags()``
- ``MessageInformation``
- ``FeatureFlagsInformation``

### Error Handling

- ``PIAAccountError``
- ``PIAMultipleErrors``
- ``PIAError``
