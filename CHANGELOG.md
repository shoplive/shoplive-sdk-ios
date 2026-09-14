# Changelog

v1 (domestic) line. One section per `<semver>` tag. Mark public API changes as breaking or
additive.

## Unreleased

## 1.9.0

### Changed

- **Minimum iOS raised from 11.0 to 15.0** for Xcode 27. Breaking for apps that still deploy
  below iOS 15; no source change is required otherwise.
- **Distribution moved to this repository.** The player and Common modules were previously
  published from `shoplive/ios-sdk` and `shoplive/common-ios` as path-based binary targets;
  they now resolve from release assets here. Those two repositories are frozen at 1.8.15.
- **The player's SPM product is now `ShopLiveSDK`**, matching its module name (previously the
  product was `ShopLive` while the module was `ShopLiveSDK`). The CocoaPods pod name is
  unchanged (`ShopLive`).
- No API changes. Apps on 1.8.11+ only need to bump the version.

### Fixed

- **Custom action `SHOW` / `KEEP` responses are no longer discarded.** The SDK emitted
  `COMPLETE_CUSTOM_ACTION` right after `CUSTOM_ACTION_RESULT`, and the web handler for that
  event removes the popup without reading the result, so the later event overwrote the earlier
  one. The event belonged to the first-generation `handleCustomAction` API and had been
  attached to the second-generation `result:` path since the 1.7.3 cleanup. Behaviour now
  matches Android.

### Notes

- **Shortform is not part of this release.** `ShopLiveShortformSDK`,
  `ShopLiveShortformEditorSDK` and `ShopliveFilterSDK` stay in their own repositories at
  1.8.13 and are unaffected. Their iOS 11 binaries run unchanged on an iOS 15 app.
- `ShopLiveCommon.shortformSdkVersion` still reports `1.8.15` by design — shortform was not
  rebuilt for this release.
