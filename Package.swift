// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// Points at the XCFramework zips attached to each release tag via binary targets.

import PackageDescription

// MARK: - Release-managed
// The six values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion        = "3.0.6"
let checksumCore      = "becc7ee93ab42d2ef03639aa1de5678d2c68120d9a094429204d9332ae4a43f3"
let checksumPlayer    = "dfa148169d902defda224a4185a3fa0e24fa7619d4d57f02288fe85d9f77b418"
let checksumStreamer  = "c31082aafec6dbcf65496f1e8d1c015c9b195a70f3573b9eb503f65fa278fbd2"
let checksumRTCHelper = "cada5a6cfd4f7577741b45819093f5d8114a9e9f535477478d710ab65f7f37e3"
let checksumWebRTC    = "e70b180ae4413cc63d497cb78395af3c50320e6b075ab820eff581af6523ee42"

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
