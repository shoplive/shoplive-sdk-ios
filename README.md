# Shoplive iOS SDK

Distribution repository for the Shoplive iOS SDK. **No SDK source lives here.**

> Canonical repo: [`shoplive/shoplive-sdk-ios`](https://github.com/shoplive/shoplive-sdk-ios)

Binaries (XCFramework zips) are published to:

| Channel | Purpose |
| --- | --- |
| **GitHub Releases** | Downloadable `*.xcframework.zip` assets per version tag |
| **`Package.swift` at the root** | Swift Package Manager binary targets resolving those assets |

Consumers never need the internal modules (`ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC`).
Declare **only** the product(s) you use — the shared binaries come bundled with each product
(same behaviour as a transitive dependency).

## Requirements

| | |
| --- | --- |
| Minimum iOS | **15.0** (see release notes if a release raises the floor) |
| Distribution | Swift Package Manager (binary targets) |
| Xcode | 15.0+ recommended (swift-tools-version 5.9) |

## Installation

### 1. Package

Xcode → `File → Add Package Dependencies…`, then enter:

```
https://github.com/shoplive/shoplive-sdk-ios
```

Use `Up to Next Major Version` as the dependency rule. On the next screen, check only the
products your app target needs.

For a package manifest, add it to `dependencies`:

```swift
dependencies: [
    .package(url: "https://github.com/shoplive/shoplive-sdk-ios", from: "3.0.0")
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

### 2. Products

#### Player only

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShoplivePlayerSDK", package: "shoplive-sdk-ios")
    ]
)
```

That single line pulls in the shared Shoplive binaries bundled with the product
(`ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC`).

#### Streamer only

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShopliveStreamerSDK", package: "shoplive-sdk-ios")
    ]
)
```

#### Player + Streamer together

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShoplivePlayerSDK", package: "shoplive-sdk-ios"),
        .product(name: "ShopliveStreamerSDK", package: "shoplive-sdk-ios")
    ]
)
```

Shared binaries (`ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC`) link once; SPM deduplicates
identical binary targets across products.

> Do **not** add `ShopliveCore` / `ShopLiveWebRTCHelperSDK` / `WebRTC` yourself unless Shoplive
> support asks you to. They are implementation details of the product SDKs, and they are not
> declared as products — so they never appear in the package-product picker.

## Products

| Product | Purpose | Bundled binaries |
| --- | --- | --- |
| `ShoplivePlayerSDK` | Live / VOD playback (HLS + WebRTC, switched internally) | `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |
| `ShopliveStreamerSDK` | Broadcasting (WebRTC + RTMP) | `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |

On **3.x**, shared auth / configuration / logging / networking surfaces ship inside
`ShopliveCore`. You only depend on the product SDK rows above.

```swift
import ShoplivePlayerSDK

Shoplive.initialize(.init(accessKey: "{ACCESS_KEY}"))
Shoplive.setUser(.guest)
```

`Shoplive.*` resolves without a second import because the Player and Streamer modules re-export
the core (`@_exported import ShopliveCore`).

## Releases

- See [Releases](https://github.com/shoplive/shoplive-sdk-ios/releases) for tagged versions and
  attached XCFramework zips.
- Tags are the bare `<semver>` (no `v` prefix); `Package.swift` resolves binaries from the
  matching tag.

## Note on "Source code" zip / tar.gz

GitHub always attaches auto-generated source archives to a Release. Those archives are **this
distribution repo** (README / manifest), not the private SDK sources.

## Ownership

- Team: Shoplive Mobile
- Contact: [ask@shoplive.cloud](mailto:ask@shoplive.cloud)
