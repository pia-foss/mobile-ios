[![PIA logo][pia-image]][pia-url]

# Private Internet Access

Private Internet Access is the world's leading consumer VPN service. At Private Internet Access we believe in unfettered access for all, and as a firm supporter of the open source ecosystem we have made the decision to open source our VPN clients. For more information about the PIA service, please visit our website [privateinternetaccess.com][pia-url] or check out the [Wiki][pia-wiki].

# Client library for Apple platforms

With this library, consumers can easily enable and communicate with the Private Internet Access services. It provides abstract interfaces for authenticating, purchasing plans, updating servers, getting connectivity updates, handling VPN profiles etc. You will also find mock objects for testing the library offline.

## Getting started

The library has been tested on both iOS and macOS and includes the following features:

- [x] Authentication
    - [x] Convenient login/signup view controllers (iOS only)
    - [x] In-app plan purchasing
- [x] Server list handling
- [x] Network connectivity
- [x] Extensible VPN profiles
- [x] Persistent preferences
- [x] Mock objects for offline testing
- [x] Theming
- [x] Convenient macros

## Installation

### Requirements

- iOS 11.0+ / macOS 10.11+
- Xcode 9+ (Swift 4)
- Git (preinstalled with Xcode Command Line Tools)
- Ruby (preinstalled with macOS)
- [SwiftGen][dep-swiftgen]
- [jazzy][dep-jazzy] (optional, for documentation)

It's highly recommended to use the Git and Ruby packages provided by [Homebrew][dep-brew].

### Swift Package Manager

To use with Swift Package Manager just add the repo as part of your packages dependencies via Xcode or via Package.swift. e.g.

```ruby
.package(url: "https://github.com/pia-foss/client-library-apple.git", from: "2.18.0")
```

## Documentation

Due to its complexity, the library is split into several modules named after their context. The *Core* and *Library* modules make up the foundation of the library and are the bare requirements.

Full documentation of the public interface is available and can be generated with [jazzy][dep-jazzy]. After installing the jazzy Ruby gem with:

    $ gem install jazzy

enter the root directory of the repository and run:

    $ jazzy

The generated output is stored into the `docs` directory in HTML format.

### Core

Here you will find the core components on top of which the library is built. These consist of:

- Business interfaces (e.g. `AccountProvider`)
- Web model (e.g. `AccountInfo`)
- Persistence model
- Callbacks (e.g. `LibraryCallback`)
- Public notifications
- Utilities (`Macros` and extensions)

### Library

The module is the default implementation of *Core*. It has an entry point called `Client`, which is the gateway to mostly every available method and variable.

The `Client` container gives access to:

- `Client.environment` - the environment in which the library operates
- `Client.configuration` - defines default and transient values/behavior
- `Client.database` - the persistency layer
- `Client.daemons` - holds information coming from passive updates
- `Client.preferences` - the model for persistent preferences
- `Client.providers` - the current implementations of Core's `*Provider` interfaces

#### Bootstrap

Before using the library, a bootstrap phase is needed through the invocation of `Client.bootstrap()`. Before the bootstrap itself, you want to take care of fine-tuning the library parameters.

Below is a typical bootstrap code:

```swift
import PIALibrary

// ...

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    Client.environment = .production
    Client.providers.vpnProvider = MockVPNProvider()
    Client.configuration.enablesServerUpdates = false
    Client.configuration.verifiesServersSignature = true
    Client.configuration.enablesConnectivityUpdates = false
    Client.bootstrap()
    // ...
    return true
}
```

that:

1. Sets the current environment to production endpoints
2. Mocks the VPN connection (especially useful on the iPhone simulator)
3. Receives notifications about server updates
4. Verifies the server list signature against the PIA public key
5. Receives notifications about connectivity (e.g. public IP address)

Remember to dispose the library at the end of the consumer lifecycle:

```swift
func applicationWillTerminate(_ application: UIApplication) {
    Client.dispose()
}
```

#### Examples

Log into PIA:

```swift
// pack auth request
let credentials = Credentials(username: "user", password: "pass")
let request = LoginRequest(credentials: credentials)

// verify credentials against PIA services
Client.providers.accountProvider.login(with: request) { (user, error) in
    guard let user = user else {
        print("Login failed: \(error)")
        return
    }

    // success, print user info
    print("Account info: \(user.info)")
}
```

Connect to the VPN:

```swift
// do this on simulator
Client.useMockVPNProvider()
Client.bootstrap()

// ...

// raw set VPN credentials (skip verify for this sample)
let credentials = Credentials(username: "user", password: "pass")
let user = UserAccount(credentials: credentials, info: nil)
Client.providers.accountProvider.currentUser = user

// establish VPN type (protocol)
let prefs = Client.preferences.editable()
prefs.vpnType = IKEv2Profile.vpnType
prefs.commit()

// observe VPN updates
NotificationCenter.default.addObserver(forName: .PIADaemonsDidUpdateVPNStatus, object: nil, queue: nil) { (notification) in
    print("VPN status: \(Client.daemons.vpnStatus)")
}

// connect
Client.providers.vpnProvider.connect(nil)
```

Get public IP notifications:

```swift
// enable passive connectivity updates
// ...
Client.configuration.enablesConnectivityUpdates = true
Client.bootstrap()

// observe connectivity updates
NotificationCenter.default.addObserver(forName: .PIADaemonsDidUpdateConnectivity, object: nil, queue: nil) { (notification) in
    guard let ip = Client.daemons.publicIP else {
        print("Unable to get public IP")
        return
    }
    print("Public IP: \(ip)")
}
```

### VPN

The *VPN* module complements part of the Library module dedicated to VPN profiles, normally based on the NetworkExtension framework for iOS and macOS.

Today, it offers the `PIATunnelProfile` bridge to integrate [TunnelKit](https://github.com/pia-foss/tunnel-apple) into the library. In the pre-bootstrap code, do something like:

```swift
let packetTunnelBundle = "com.example.MyApp.MyTunnel"
let group = "group.com.example"
let ca = OpenVPN.CryptoContainer(pem: """
-----BEGIN CERTIFICATE-----
MIIFqzCCBJOgAwIBAgIJAKZ7D5Yv87qDMA0GCSqGSIb3DQEBDQUAMIHoMQswCQYD
-----END CERTIFICATE-----
""")

var sessionBuilder = OpenVPN.ConfigurationBuilder()
sessionBuilder.cipher = .aes128gcm
sessionBuilder.digest = .sha1

var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: sessionBuilder.build())
builder.mtu = 1350
        
Client.configuration.addVPNProfile(
    PIATunnelProfile(bundleIdentifier: packetTunnelBundle)
)
Client.preferences.defaults.vpnCustomConfigurations = [
    PIATunnelProfile.vpnType: builder.build()
]
```

to enable it as a VPN type in `Client.preferences.vpnType`.

### Mock

With mock providers, you can simulate library behavior without actually touching real business. For example, you might want to test login code in your app without submitting credentials to the PIA web services.

Each area of the library has its mock counterpart:

- `MockAccountProvider`
- `MockServerProvider`
- `MockVPNProvider`
- `MockInAppProvider` (internal)

After configuration, put your mock provider into the proper field of `Client.providers` before bootstrap. For example:

```swift
let mock = MockAccountProvider()
mock.mockPlan = .trial
mock.mockIsExpiring = true
mock.mockIsRenewable = true

Client.providers.accountProvider = mock
Client.bootstrap()
```

All providers have [shortcuts](/PIALibrary/Sources/Mock/Client+Mock.swift) in `Client`, so you can do more concisely:

```swift
...
Client.useMockAccountProvider(mock)
Client.bootstrap()
```

which for in-app mocking is actually the only way, being it non-customizable:

```swift
Client.useMockInAppProvider()
```

### UI

Most of this module makes more sense for use in our own apps. The module is almost iOS only and includes:

- Useful macros
- Some custom views and view controllers
- Form validation
- Theming support
- Welcome view controllers

The `Theme` class helps the consumer app comply with a set of styles. Rather than explicitly setting colors and fonts, we centralize the typography definition in a `Theme.Palette` (colors) and a `Theme.Typeface` (fonts), to later use `Theme` methods to apply symbolic styles.

In such a setup, the use of `AutolayoutViewController` allows dynamic theme changes across the whole app.

`PIAWelcomeViewController` is a quick user interface to support login and signup to the PIA services in an app.

### Util

Generic utility classes and extensions.

## Known issues

### macOS support

There is some overlooked difference between the iOS and macOS keychain that breaks the loading of the PIA public key, needed for servers verification.

## Contributing

By contributing to this project you are agreeing to the terms stated in the Contributor License Agreement (CLA) [here](/CLA.rst).

For more details please see [CONTRIBUTING](/CONTRIBUTING.md).

Issues and Pull Requests should use these templates: [ISSUE](/.github/ISSUE_TEMPLATE.md) and [PULL REQUEST](/.github/PULL_REQUEST_TEMPLATE.md).

## Authors

- Jose Blaya - [ueshiba](https://github.com/ueshiba)
- Davide De Rosa 

## License

This project is licensed under the [MIT (Expat) license](https://choosealicense.com/licenses/mit/), which can be found [here](/LICENSE).

## Acknowledgements

- SwiftyBeaver - © 2015 Sebastian Kreutzberger
- Gloss - © 2017 Harlan Kellaway
- Alamofire - © 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
- ReachabilitySwift - © 2016 Ashley Mills
- TunnelKit - © 2018 - Present Davide de Rosa (https://github.com/passepartoutvpn/tunnelkit) - TunnelKit is not MIT software and remains under the terms of the GPL license (https://github.com/passepartoutvpn/tunnelkit/blob/master/LICENSE)

[pia-image]: https://www.privateinternetaccess.com/assets/PIALogo2x-0d1e1094ac909ea4c93df06e2da3db4ee8a73d8b2770f0f7d768a8603c62a82f.png
[pia-url]: https://www.privateinternetaccess.com/
[pia-wiki]: https://en.wikipedia.org/wiki/Private_Internet_Access

[dep-swiftgen]: https://github.com/SwiftGen/SwiftGen
[dep-jazzy]: https://github.com/realm/jazzy
[dep-brew]: https://brew.sh/

[ne-home]: https://developer.apple.com/documentation/networkextension
[ne-ptp]: https://developer.apple.com/documentation/networkextension/nepackettunnelprovider
