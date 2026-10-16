// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// Points at the XCFramework zips attached to each release tag via binary targets.

import PackageDescription

// MARK: - Release-managed
// The six values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion        = "3.0.2"
let checksumCore      = "0ead2c64147fc195dc647b93ac1c5da71c37b4e0bc98e40604b9dc0ada63f81c"
let checksumPlayer    = "c52249cd448f1e98a92e72b10a18839b4b4c1646fa383d17c6681a5d8f8715dc"
let checksumStreamer  = "5fb82b8f1c0f253faedd67c252038a029fe256ee519d09318f5cf17b2cf37b4c"
let checksumRTCHelper = "66238f7dcb0ffe7bc0eb8cd2bbdf617302d9f0585f41e543a5409daf49cd293f"
let checksumWebRTC    = "2e089365df502588e6fc8720ce09ca910d00011a7bdf6676f97c495d266f81ef"

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
