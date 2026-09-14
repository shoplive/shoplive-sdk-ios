# Changelog

v1 (domestic) line. One section per `<semver>` tag. Mark public API changes as breaking or
additive.

## Unreleased

## 1.9.0

- **Minimum iOS raised from 11.0 to 15.0** for Xcode 27. Breaking for apps that still deploy
  below iOS 15; no source change is required otherwise.
- **Distribution moved to this repository.** The player and Common modules were previously
  published from `shoplive/ios-sdk` and `shoplive/common-ios` as path-based binary targets;
  they now resolve from release assets here. Those two repositories are frozen at 1.8.15.
- **Shortform is not part of this release.** `ShopLiveShortformSDK`,
  `ShopLiveShortformEditorSDK` and `ShopliveFilterSDK` stay in their own repositories at
  1.8.13 and are unaffected. Their iOS 11 binaries run unchanged on an iOS 15 app.
- The player's SPM product is now `ShopLiveSDK`, matching its module name (previously the
  product was `ShopLive` while the module was `ShopLiveSDK`). The CocoaPods pod name is
  unchanged (`ShopLive`).
- No API changes. Apps on 1.8.11+ only need to bump the version.
