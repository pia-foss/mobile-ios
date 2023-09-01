[![PIA logo][pia-image]][pia-url]

# Private Internet Access

Private Internet Access is the world's leading consumer VPN service. At Private Internet Access we believe in unfettered access for all, and as a firm supporter of the open source ecosystem we have made the decision to open source our VPN clients. For more information about the PIA service, please visit our website [privateinternetaccess.com][pia-url] or check out the [Wiki][pia-wiki].

# WireGuard library for iOS

This library provides a simplified Swift implementation of the WireGuard® protocol for iOS, while also taking advantage of the Private Internet Access.

## Getting started

This library is based in the WireGuard® library for Apple platforms from Jason A. Donenfeld (https://github.com/WireGuard/wireguard-apple).

The library uses 2 scripts to generate the WireGuard framework.

- wireguard-go-bridge/build.sh
- create-libwg-go-xcframework.sh

Together they generate a `PIAWireguardGo.xcframework` under the `frameworks/` directory for the following archs `arm64 armv7 x86_64`.

## Installation

### Requirements

- iOS 12.0+
- Xcode 10+ (Swift 5)
- Go 1.17
- Git (preinstalled with Xcode Command Line Tools)

### Swift Package Manager

To use with Swift Package Manager just add the repo as part of your packages dependencies via Xcode or via Package.swift. e.g.

```ruby
.package(url: "https://github.com/pia-foss/ios-wireguard", from: "1.1.0")
```
    
## Documentation

The library is split into two modules, in order to decouple the low-level protocol implementation from the platform-specific bridging, namely the [NetworkExtension][ne-home] VPN framework.

### How it works

You need to implement an endpoint in your server where you can add the public key generated from the library before to establish the connection with the WireGuard® server. This server should return a `WGServerResponse` json object. The information retrieved from the request, is used to set the tunnel settings, as IP, DNS, etc. 

With the `WGServerResponse` json object response, you need to create the uapi configuration as `Go` string and start the tunnel.

To check the connectivity inside the tunnel we compare the received bytes every `connectivityInterval` seconds. If after `wireGuardMaxConnectionAttempts` attempts we don't see an increment, we start to make ICMP pings to the `pingAddress` hostname or IP every `pingInterval` until we see the increment for a max of `wireGuardMaxConnectionAttempts`. If after send the pings we still don't see an increment in the received bytes, we stop the tunnel.

### Core

Here you will find the WireGuard® utility classes and the low-level entities that we need to use from the AppExtension module. Crypto, Logger and WireGuard® classes are in this module. The *Core* module depends on Alamofire and is mostly platform-agnostic.

### AppExtension

The goal of this module is packaging up a black box implementation of a [NEPacketTunnelProvider][ne-ptp], which is the essential part of a Packet Tunnel Provider app extension. You will find the main implementation in the `WGPacketTunnelProvider` class.

There are different `WGPacketTunnelProvider` class extensions to separate Message, Connectivity, API methods. 

Currently, WireGuard® VPN only works over UDP.

## Contributing

By contributing to this project you are agreeing to the terms stated in the Contributor License Agreement (CLA) [here](/CLA.rst).

For more details please see [CONTRIBUTING](/CONTRIBUTING.md).

Issues and Pull Requests should use these templates: [ISSUE](/.github/ISSUE_TEMPLATE.md) and [PULL REQUEST](/.github/PULL_REQUEST_TEMPLATE.md).

## Authors

- Jose Blaya - [ueshiba](https://github.com/ueshiba)

## License

This project is licensed under the [MIT (Expat) license](https://choosealicense.com/licenses/mit/), which can be found [here](/LICENSE).

## Acknowledgements

- WireGuard® - © Jason A. Donenfeld (https://github.com/WireGuard/wireguard-apple)
- Alamofire - © 2014-2020 Alamofire Software Foundation (http://alamofire.org/)

[pia-image]: https://www.privateinternetaccess.com/assets/PIALogo2x-0d1e1094ac909ea4c93df06e2da3db4ee8a73d8b2770f0f7d768a8603c62a82f.png
[pia-url]: https://www.privateinternetaccess.com/
[pia-wiki]: https://en.wikipedia.org/wiki/Private_Internet_Access

[ne-home]: https://developer.apple.com/documentation/networkextension
[ne-ptp]: https://developer.apple.com/documentation/networkextension/nepackettunnelprovider
