// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// Points at the XCFramework zips attached to each release tag via binary targets.

import PackageDescription

// MARK: - Release-managed
// The six values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion        = "3.0.1"
let checksumCore      = "fd1700fe1c2d5d26691ad6d593aa5aa6f713a359bb4ddacac6305c4ec5ecb6bb"
let checksumPlayer    = "49e7e37b0937c981dd566f372ed10e93d0b3e1084c390490ce643ab83dbe384c"
let checksumStreamer  = "96da22684dc1c5e9efdc60af310e8b2ab7371a42b274fcab3e007962dc4b2dab"
let checksumRTCHelper = "5925dce0dae598bc650a337c9bb324ef2724b93c75151230474d72a56f35cc29"
let checksumWebRTC    = "e19f9522128f58d8e2516e6a23925f5be16cffde817f010062a2850793de7de6"

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
