# Shoplive iOS SDK

Distribution repo for the Shoplive iOS SDK, shipped as **XCFrameworks**. No source lives here.
Every release tag carries the XCFramework zips, and the `Package.swift` at the root points at
them as Swift Package Manager binary targets.

## Requirements

| | |
| --- | --- |
| Minimum iOS | **15.0** |
| Distribution | Swift Package Manager (binary targets) |
| Xcode | 15.0+ (swift-tools-version 5.9) |

> The iOS 15 floor comes from the playback and broadcasting paths already sitting at 15.
> Dropping to iOS 13 is gated on confirming the min deployment target of the rtc-ios binary
> ([Deployment Target Guide](https://shoplive.atlassian.net/wiki/spaces/MO/pages/1741717512)).

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
the core (`@_exported import ShopliveCore`). See the
[Unified SDK Public Interface design doc](https://shoplive.atlassian.net/wiki/spaces/MO/pages/1739292725)
for the public API itself.

## Cutting a release

XCFrameworks are built in the SDK source repo; this repo only takes the artifacts and ships them.

1. Get the five zips from the SDK source repo, collected in one directory. File names and the
   zip's root layout are fixed — the names are what the download URLs in `Package.swift` point
   at, so they carry no version suffix:

   ```
   ShopliveCore.xcframework.zip            → ShopliveCore.xcframework/ at the root
   ShoplivePlayerSDK.xcframework.zip       → ShoplivePlayerSDK.xcframework/ at the root
   ShopliveStreamerSDK.xcframework.zip     → ShopliveStreamerSDK.xcframework/ at the root
   ShopLiveWebRTCHelperSDK.xcframework.zip → ShopLiveWebRTCHelperSDK.xcframework/ at the root
   WebRTC.xcframework.zip                  → WebRTC.xcframework/ at the root
   ```

2. Run the release script here, pointing it at that directory. It computes checksums, rewrites
   `Package.swift`, commits and tags — **locally only**.

   ```bash
   scripts/release.sh 1.0.0 <zips-dir>
   ```

3. Review, then publish (or pass `--publish` in step 2 to do both at once):

   ```bash
   git push origin HEAD 1.0.0
   gh release create 1.0.0 --title 1.0.0 --generate-notes dist/*.zip
   ```

Once the tag lands, the `verify` workflow checks that the tag matches `sdkVersion` and that every
asset is attached.

### Rules

- The six values at the top of `Package.swift` (`sdkVersion`, `checksum*`) are **script-owned**.
- Tags are the bare `<semver>` — no `v` prefix. The download URLs in `Package.swift` are
  assembled from the tag name, so the two have to match exactly.
- XCFramework binaries are never committed — Releases only (enforced by `.gitignore`).

## Ownership

- Team: `shoplive-mobile` (see CODEOWNERS)
- Catalog: [shopstage catalog](https://internal.shoplive.cloud/shopstage/catalog)
