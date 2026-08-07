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

> The iOS 15 floor comes from the unified Player embedding the WebRTC engine in a single binary,
> plus the broadcasting path already sitting at 15. Dropping to iOS 13 is gated on confirming the
> min deployment target of the rtc-ios binary
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
| `ShoplivePlayerSDK` | Playback (HLS + WebRTC, switched internally) | `ShoplivePlayerSDK`, `ShopliveCore` |
| `ShopliveStreamerSDK` | Broadcasting (WebRTC) | `ShopliveStreamerSDK`, `ShopliveCore` |

**You never add `ShopliveCore` yourself.** It is the shared core for auth, configuration,
logging and networking, and it ships inside both products, so it is linked and embedded
automatically. Using Player and Streamer together still pulls the Core binary in exactly once.

```swift
import ShoplivePlayerSDK

Shoplive.initialize(.init(accessKey: "{ACCESS_KEY}"))
Shoplive.setUser(.guest)
```

> Reaching `Shoplive.*` through `import ShoplivePlayerSDK` alone requires the SDK sources to
> re-export it with `@_exported import ShopliveCore`. Until that lands, add `import ShopliveCore`
> as well — no extra package needed, the binary is already linked. See the
> [Unified SDK Public Interface design doc](https://shoplive.atlassian.net/wiki/spaces/MO/pages/1739292725)
> for the public API itself.

## Cutting a release

XCFrameworks are built in the SDK source repo; this repo only takes the artifacts and ships them.

1. Build the three modules in the SDK source repo and zip them. File names and the zip's root
   layout are fixed:

   ```
   ShopliveCore.xcframework.zip        → ShopliveCore.xcframework/ at the root
   ShoplivePlayerSDK.xcframework.zip   → ShoplivePlayerSDK.xcframework/ at the root
   ShopliveStreamerSDK.xcframework.zip → ShopliveStreamerSDK.xcframework/ at the root
   ```

2. Run the release script here. It computes checksums, rewrites `Package.swift`, commits and
   tags — **locally only**.

   ```bash
   scripts/release.sh 1.0.0 \
     dist/ShopliveCore.xcframework.zip \
     dist/ShoplivePlayerSDK.xcframework.zip \
     dist/ShopliveStreamerSDK.xcframework.zip
   ```

3. Review, then publish (or pass `--publish` in step 2 to do both at once):

   ```bash
   git push origin HEAD v1.0.0
   gh release create v1.0.0 --title v1.0.0 --generate-notes dist/*.zip
   ```

Once the tag lands, the `verify` workflow checks that the tag matches `sdkVersion` and that all
three assets are attached.

### Rules

- The four values at the top of `Package.swift` (`sdkVersion`, `checksum*`) are **script-owned**.
- Tags are `v<semver>`; the download URLs in `Package.swift` are assembled from the tag name.
- XCFramework binaries are never committed — Releases only (enforced by `.gitignore`).

## Ownership

- Team: `shoplive-mobile` (see CODEOWNERS)
- Catalog: [shopstage catalog](https://internal.shoplive.cloud/shopstage/catalog)
