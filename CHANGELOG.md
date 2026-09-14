# Changelog

v1 (domestic) line. One section per `<semver>` tag. Mark public API changes as breaking or
additive.

## Unreleased

## 1.9.0

- **Minimum iOS raised from 11.0 to 15.0** for Xcode 27. Breaking for apps that still deploy
  below iOS 15; no source change is required otherwise.
- **Distribution moved to this repository.** The player and Common modules were previously
  published from `shoplive/ios-sdk` and `shoplive/common-ios` as path-based binary targets;
  they now resolve from release assets here. Shortform and its editor keep their own
  repositories for CocoaPods and are mirrored into this manifest as release assets.
- The player's SPM product is now `ShopLiveSDK`, matching its module name (previously the
  product was `ShopLive` while the module was `ShopLiveSDK`). The CocoaPods pod name is
  unchanged (`ShopLive`).
- No API changes. Apps on 1.8.11+ only need to bump the version.
