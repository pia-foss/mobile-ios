[![PIA logo][pia-image]][pia-url]

# Private Internet Access

Private Internet Access is the world's leading consumer VPN service. At Private Internet Access we believe in unfettered access for all, and as a firm supporter of the open source ecosystem we have made the decision to open source our VPN clients. For more information about the PIA service, please visit our website [privateinternetaccess.com][pia-url] or check out the [Wiki][pia-wiki].

# PIA VPN for iOS

With the Private Internet Access VPN app for iOS, you can access our network of VPN servers across the world from your iPhone, iPad or iPod touch (64-bit only). Choose among many available countries and connect to them easily. Features include automatic reconnection, multiple VPN protocols, DNS/IPv6 leak protection and Safari Content Blocker for ad-blocking while browsing with Safari.

## Getting started

The PIA VPN app features:

- [x] Plenty of countries to connect to (28 as of today)
- [x] Automatic reconnection
- [x] Multiple VPN protocols
- [x] Fine-grained VPN settings
- [x] DNS leak protection
- [x] IPv6 leak protection
- [x] Safari Content Blocker
- [x] Dark theme

## Installation

### Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 9+ (Swift 4)
- Git (preinstalled with Xcode Command Line Tools)
- Ruby (preinstalled with macOS)
- [CocoaPods 1.5.0][dep-cocoapods]

It's highly recommended to use the Git and Ruby packages provided by [Homebrew][dep-brew].

### Testing

Download the app codebase locally:

    $ git clone https://github.com/pia-foss/vpn-ios.git

Assuming you have a [working CocoaPods environment][dep-cocoapods], setting up the app workspace only requires installing the pod dependencies:

    $ pod install

After that, open `PIA VPN.xcworkspace` in Xcode and run the `PIA VPN` target.

For the VPN to work properly, the app requires:

- _App Groups_ and _Keychain Sharing_ capabilities
- App IDs with _Packet Tunnel_ entitlements

both in the main app and the tunnel extension target.

## Contributing

By contributing to this project you are agreeing to the terms stated in the Contributor License Agreement (CLA) [here](/CLA.rst).

For more details please see [CONTRIBUTING](/CONTRIBUTING.md).

Issues and Pull Requests should use these templates: [ISSUE](/.github/ISSUE_TEMPLATE.md) and [PULL REQUEST](/.github/PULL_REQUEST_TEMPLATE.md).

## Authors

- Davide De Rosa - [keeshux](https://github.com/keeshux)
- Amir Malik (before 2016)

## License

This project is licensed under the [MIT (Expat) license](https://choosealicense.com/licenses/mit/), which can be found [here](/LICENSE).

## Acknowledgements

- SwiftyBeaver - © 2015 Sebastian Kreutzberger
- Alamofire - © 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
- iRate - © 2011 Charcoal Design
- TPKeyboardAvoiding - © 2013 Michael Tyson
- SideMenu - © 2015 Jonathan Kent <contact@jonkent.me>
- FXPageControl - © 2010 Charcoal Design
- MBProgressHUD - © 2009-2016 Matej Bukovinski

© 2002-2018 OpenVPN Inc. - OpenVPN is a registered trademark of OpenVPN Inc.

[pia-image]: https://www.privateinternetaccess.com/assets/PIALogo2x-0d1e1094ac909ea4c93df06e2da3db4ee8a73d8b2770f0f7d768a8603c62a82f.png
[pia-url]: https://www.privateinternetaccess.com/
[pia-wiki]: https://en.wikipedia.org/wiki/Private_Internet_Access

[dep-cocoapods]: https://guides.cocoapods.org/using/getting-started.html
[dep-jazzy]: https://github.com/realm/jazzy
[dep-brew]: https://brew.sh/
