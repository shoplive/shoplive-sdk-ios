# Shoplive iOS SDK

The Shoplive iOS SDK, distributed as **XCFrameworks** via Swift Package Manager. Every release
tag carries the XCFramework zips, and the `Package.swift` at the root points at them as binary
targets.

## Requirements

| | |
| --- | --- |
| Minimum iOS | **15.0** |
| Distribution | Swift Package Manager (binary targets) |
| Xcode | 15.0+ (swift-tools-version 5.9) |

## Installation

### Xcode

`File → Add Package Dependencies…`, then enter:

```
https://github.com/shoplive/shoplive-sdk-ios
```

Use `Up to Next Major Version` as the dependency rule. On the next screen, check only the
products your app target needs.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/shoplive/shoplive-sdk-ios", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ShoplivePlayerSDK", package: "shoplive-sdk-ios")
        ]
    )
]
```

## Modules

| Product | Purpose | Bundled XCFrameworks |
| --- | --- | --- |
| `ShoplivePlayerSDK` | Playback (HLS + WebRTC, switched internally) | `ShoplivePlayerSDK`, `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |
| `ShopliveStreamerSDK` | Broadcasting (WebRTC + RTMP) | `ShopliveStreamerSDK`, `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |

**Two products, and you import only those two.** Everything else in the table is an
implementation detail that ships alongside them:

- `ShopliveCore` — shared auth, configuration, logging and networking
- `ShopLiveWebRTCHelperSDK` — signalling helper used by both products
- `WebRTC` — the Google WebRTC binary (~34MB dynamic framework, so it stays separate)

None of these are products, so they never appear in the package-product picker, and you never
add them yourself. Using Player and Streamer together still links each shared binary exactly once.

```swift
import ShoplivePlayerSDK

Shoplive.initialize(.init(accessKey: "{ACCESS_KEY}"))
Shoplive.setUser(.guest)
```

`Shoplive.*` resolves without a second import because the Player and Streamer modules re-export
the core (`@_exported import ShopliveCore`).

## Support

Questions and issue reports: contact your Shoplive representative.
