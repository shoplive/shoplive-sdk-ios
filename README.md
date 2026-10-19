# Shoplive iOS SDK — v1 line

The Shoplive iOS SDK (domestic v1 line), distributed as XCFrameworks. Binaries
(`*.xcframework.zip`) are attached to each GitHub Release, and the `Package.swift` on this
branch resolves them as Swift Package Manager binary targets.

> **This repository ships two lines.** `main` carries the 3.x unified SDK; this `release/v1`
> branch carries the 1.x line. SwiftPM only reads the manifest stored in the tag it resolves,
> so the two never meet in a single resolution, and their product / target names do not
> overlap.
>
> **Do not merge this branch into `main`.** Merging would overwrite the 3.x manifest and break
> 3.x distribution. `release/v1` is the 1.x line's own base branch: 1.x work branches off it
> and merges back into it, never into `main`.

## Requirements

| | |
| --- | --- |
| Minimum iOS | **15.0** (raised from 11.0 in 1.9.0 for Xcode 27) |
| Distribution | Swift Package Manager (binary targets) · CocoaPods |
| Xcode | 15.0+ recommended (swift-tools-version 5.9) |

## Installation (SPM)

In Xcode, go to `File → Add Package Dependencies…` and enter:

```
https://github.com/shoplive/shoplive-sdk-ios
```

**Set the dependency rule to `Up to Next Major Version` with `1.9.0` as the base.** The 3.x
line lives in this same repository, so anchoring to 1.9.0 keeps resolution inside the 1.x
range.

For a package manifest:

```swift
dependencies: [
    .package(url: "https://github.com/shoplive/shoplive-sdk-ios", .upToNextMajor(from: "1.9.1")),
    .package(url: "https://github.com/shoplive/common-ios", exact: "1.9.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ShopLiveSDK",       package: "shoplive-sdk-ios"),
            // Common 은 1.9.1 부터 shoplive/common-ios 패키지가 싣는다 (ShopLiveSDK 가 의존으로 끌어온다).
            // 앱 코드에서 `import ShopliveSDKCommon` 을 쓰면 명시한다:
            .product(name: "ShopliveSDKCommon", package: "common-ios")
        ]
    )
]
```

## Products

| Product | Required | Purpose | `import` |
| --- | --- | --- | --- |
| `ShopLiveSDK` | ✅ | Live player · PIP | `ShopLiveSDK` |
| `ShopliveSDKCommon` (package **`common-ios`**) | ✅ | Auth (access key) · user settings · shared API | `ShopliveSDKCommon` |

`ShopliveAPI` ships inside the `ShopliveSDKCommon` product as a target rather than a product of
its own, so there is nothing extra to add.

> **Common moved to `shoplive/common-ios` (1.9.1~).** `ShopLiveSDK` declares `common-ios` as a
> dependency, so Common resolves with it. Shortform and the shortform editor declare the same
> package, which lets SwiftPM resolve Common once — and lets 3.x apps add shortform, since they no
> longer need this repository at two versions. Migration from 1.9.0: change
> `.product(name: "ShopliveSDKCommon", package: "shoplive-sdk-ios")` to `package: "common-ios"`.

### Shortform

Shortform and the shortform editor are **not** distributed from this repository. Keep using
their own packages:

| Module | Repository |
| --- | --- |
| `ShopLiveShortformSDK` | [shoplive/shortform-ios](https://github.com/shoplive/shortform-ios) |
| `ShopLiveShortformEditorSDK` · `ShopliveFilterSDK` | [shoplive/shortform-editor-ios](https://github.com/shoplive/shortform-editor-ios) |

> ⚠️ **Shortform 1.8.13 is not compatible with Common 1.8.15 or later (including 1.9.0).** Common
> 1.8.15 moved `SLHTTPMethod`, `APIDefinition`, `BaseResponsable`, `ShopLiveCommonError` and others
> into the `ShopliveAPI` module without `@_originallyDefinedIn`; the 1.8.13 shortform binaries still
> reference them in `ShopliveSDKCommon`, so dyld stops the app at launch (`Symbol not found`).
> Use shortform **1.9.0** (built against Common 1.9.0, declares `common-ios`) with this release, or
> stay on player 1.8.14 + Common 1.8.14 + shortform 1.8.13.

> The product name and the module name differ for the player: the product is `ShopLiveSDK` and
> so is the module, but earlier releases published the same binary under a product named
> `ShopLive` from the `shoplive/ios-sdk` repository. Import `ShopLiveSDK`.

## Installation (CocoaPods)

CocoaPods specs are published to the Shoplive spec repo, not the CocoaPods trunk. Declare both
sources — naming any source disables the implicit default CDN, and omitting the official CDN
breaks every *other* pod in your Podfile.

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/shoplive/pod-specs.git'

platform :ios, '15.0'
use_frameworks!

target 'YourApp' do
  pod 'ShopLive',          '1.9.0'
  pod 'ShopliveSDKCommon', '1.9.0'

  # Shortform keeps its own version line
  # pod 'ShopliveShortformSDK', '1.8.13'
end
```

The pod is still named `ShopLive` (unchanged from 1.8.x), while the module it vendors is
`ShopLiveSDK`.

Use SPM **or** CocoaPods, never both — installing through both duplicates symbols.

## Releasing (1.x)

`release/v1` is the base branch for this line. It is never merged into `main`, and no
per-version branch is kept around — the two long-lived branches are `main` (3.x) and
`release/v1` (1.x).

A release goes:

1. Branch off `release/v1` (e.g. `release/1.9.1`)
2. `scripts/release.sh <version> <zips-dir> --no-tag` — rewrites the release-managed values
   in `Package.swift` and commits
3. Open a PR into `release/v1` and merge it
4. Tag the merge commit, then publish the release with `--latest=false` and attach the zips

`--no-tag` exists for exactly this: the tag has to sit on the merged commit, which does not
exist while the PR is still open.

The XCFrameworks are built in the SDK source repo (`matrix-sdk-ios`, domestic line). This
repo only ships them.

## Releases

- See [Releases](https://github.com/shoplive/shoplive-sdk-ios/releases) for tagged versions and
  attached XCFramework zips.
- Tags are the bare `<semver>` (no `v` prefix); `Package.swift` resolves binaries from the
  matching tag.
- **1.x releases are published with `--latest=false`.** The repository's *Latest* badge belongs
  to the 3.x line. Neither SwiftPM nor CocoaPods reads that badge, so it affects only what a
  visitor sees first.

> **On the "Source code" zip / tar.gz assets:** GitHub always attaches auto-generated source
> archives to a Release. Those archives are **this distribution repo** (README / manifest), not
> the private SDK sources.

## Ownership & Support

- Team: Shoplive Mobile
- Contact: [ask@shoplive.cloud](mailto:ask@shoplive.cloud)
