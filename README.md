# Shoplive iOS SDK

The Shoplive Android SDK, distributed as XCFrameworks. Binaries (`*.xcframework.zip`) are attached to each GitHub Release, and the `Package.swift` at the root resolves them as Swift Package Manager binary targets.

## Requirements

| | |
| --- | --- |
| Minimum iOS | **15.0** (see release notes if a release raises the floor) |
| Distribution | Swift Package Manager (binary targets) |
| Xcode | 15.0+ recommended (swift-tools-version 5.9) |

## Installation

### 1. Add the package (SPM)

In Xcode, go to `File → Add Package Dependencies…` and enter:

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

### 2. Dependencies

The SDK has **no third-party dependencies you need to declare**. Each product bundles the
shared Shoplive binaries it needs, so declaring the product is enough:

| Product | Bundled binaries |
| --- | --- |
| `ShoplivePlayerSDK` | `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |
| `ShopliveStreamerSDK` | `ShopliveCore`, `ShopLiveWebRTCHelperSDK`, `WebRTC` |

If you use both products, the shared binaries link once — SPM deduplicates identical binary
targets across products.

> Do **not** add `ShopliveCore` / `ShopLiveWebRTCHelperSDK` / `WebRTC` yourself unless Shoplive
> support asks you to. They are implementation details of the product SDKs, and they are not
> declared as products — so they never appear in the package-product picker.

### 3. Products

| Product | Purpose |
| --- | --- |
| `ShoplivePlayerSDK` | Live / VOD playback (HLS + WebRTC, switched internally) |
| `ShopliveStreamerSDK` | Broadcasting (WebRTC + RTMP) |

#### Player only

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShoplivePlayerSDK", package: "shoplive-sdk-ios")
    ]
)
```

#### Streamer only

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShopliveStreamerSDK", package: "shoplive-sdk-ios")
    ]
)
```

#### All (Player + Streamer)

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "ShoplivePlayerSDK", package: "shoplive-sdk-ios"),
        .product(name: "ShopliveStreamerSDK", package: "shoplive-sdk-ios")
    ]
)
```

Once resolved, import the product you declared:

```swift
import ShoplivePlayerSDK

Shoplive.initialize(.init(accessKey: "{ACCESS_KEY}"))
Shoplive.setUser(.guest)
```

On **3.x**, shared auth / configuration / logging / networking surfaces ship inside
`ShopliveCore`. `Shoplive.*` resolves without a second import because the Player and Streamer
modules re-export the core (`@_exported import ShopliveCore`).

## Releases

- See [Releases](https://github.com/shoplive/shoplive-sdk-ios/releases) for tagged versions and
  attached XCFramework zips.
- Tags are the bare `<semver>` (no `v` prefix); `Package.swift` resolves binaries from the
  matching tag.
- Each release lists the version's changes; check the notes before bumping, especially for a
  raised minimum iOS version.

> **On the "Source code" zip / tar.gz assets:** GitHub always attaches auto-generated source
> archives to a Release. Those archives are **this distribution repo** (README / manifest), not
> the private SDK sources.

## Ownership & Support

- Team: Shoplive Mobile
- Contact: [ask@shoplive.cloud](mailto:ask@shoplive.cloud)
