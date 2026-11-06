// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// Points at the XCFramework zips attached to each release tag via binary targets.

import PackageDescription

// MARK: - Release-managed
// The six values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion        = "3.0.5"
let checksumCore      = "acf9e29efd58daf85d8d0ebbc4f4be3cd30f732874dc7c9c78870ddb88c27d24"
let checksumPlayer    = "3c58e4a88ac53f8b52232fe5e032e94f3384675f681743d513479a1d1627c9e8"
let checksumStreamer  = "8bd19a85338f36ded6af03e53b282160a9f87c6a6a1dca82de8bd6ee5707068c"
let checksumRTCHelper = "e5d64f511edc10ee0ddb07f5e74dc7dcd606de0eb999010405bb55395b3388f8"
let checksumWebRTC    = "404db28c04852434a0736e44cd5c22c49e6a99ec6ca3f0d66a4b0da0626bb601"

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
