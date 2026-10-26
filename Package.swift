// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// Points at the XCFramework zips attached to each release tag via binary targets.

import PackageDescription

// MARK: - Release-managed
// The six values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion        = "3.0.4"
let checksumCore      = "cd3863c84083502e19bc31ff4cd4ee0ce80f87c801c74313ff5d0eedc182496e"
let checksumPlayer    = "838afe9b2ac6c7138263d6a587ab639b86a658476d1f713e6748f6cafb3177de"
let checksumStreamer  = "3ff21d2b0cd54901453c03032c6262a8df7bdc4210c4cb09a9dbad2f96d1cd9b"
let checksumRTCHelper = "51fc359474886a7e0db7317c1b3b8105dd6c8e97add557e0d2c9b4ad42eea6b5"
let checksumWebRTC    = "6f3f27ace9f7726acaffd040e873cccbf0fa009c225347976d6d7164325c66f9"

// MARK: -

let releaseBase = "https://github.com/shoplive/shoplive-sdk-ios/releases/download/\(sdkVersion)"

let package = Package(
    name: "ShopliveSDK",
    platforms: [
        // The whole streaming path is already on 15, so iOS 15 is the floor.
        .iOS(.v15)
    ],
    products: [
        // Two products, and only two. The three shared binaries below are listed inside each
        // product's targets rather than as products of their own, so integrators pick one
        // library and get everything it needs — and never import Core directly, because the
        // Player and Streamer modules re-export it (`@_exported import ShopliveCore`).
        .library(
            name: "ShoplivePlayerSDK",
            targets: [
                "ShoplivePlayerSDK",
                "ShopliveCore",
                "ShopLiveWebRTCHelperSDK",
                "WebRTC"
            ]
        ),
        .library(
            name: "ShopliveStreamerSDK",
            targets: [
                "ShopliveStreamerSDK",
                "ShopliveCore",
                "ShopLiveWebRTCHelperSDK",
                "WebRTC"
            ]
        )
    ],
    targets: [
        // Playback: one module covering both HLS and WebRTC, switched internally
        .binaryTarget(
            name: "ShoplivePlayerSDK",
            url: "\(releaseBase)/ShoplivePlayerSDK.xcframework.zip",
            checksum: checksumPlayer
        ),
        // Broadcasting: WebRTC and RTMP ingest
        .binaryTarget(
            name: "ShopliveStreamerSDK",
            url: "\(releaseBase)/ShopliveStreamerSDK.xcframework.zip",
            checksum: checksumStreamer
        ),
        // Shared core: auth, configuration, logging, networking (bundle id cloud.shoplive.core)
        .binaryTarget(
            name: "ShopliveCore",
            url: "\(releaseBase)/ShopliveCore.xcframework.zip",
            checksum: checksumCore
        ),

        // The two below are implementation detail, not part of the documented surface.
        // They ship because Player and Streamer link against them — verified in the generated
        // interfaces, both of which carry `import ShopLiveWebRTCHelperSDK` and `import WebRTC`.
        // Omitting either breaks module verification on the integrator's side.

        // Signalling helper shared by playback and broadcasting
        .binaryTarget(
            name: "ShopLiveWebRTCHelperSDK",
            url: "\(releaseBase)/ShopLiveWebRTCHelperSDK.xcframework.zip",
            checksum: checksumRTCHelper
        ),
        // Google WebRTC. A ~34MB dynamic framework, so it cannot be folded into the modules
        // that use it.
        .binaryTarget(
            name: "WebRTC",
            url: "\(releaseBase)/WebRTC.xcframework.zip",
            checksum: checksumWebRTC
        )
    ]
)
