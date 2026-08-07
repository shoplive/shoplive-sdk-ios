// swift-tools-version: 5.9
// Shoplive iOS SDK — XCFramework distribution manifest.
//
// This repository holds no source. It only points at the XCFramework zips attached to each
// release tag via binary targets. (Design doc: Unified SDK Public Interface §1 Module Layout)

import PackageDescription

// MARK: - Release-managed
// The four values below are rewritten by scripts/release.sh. Do not edit them by hand.
// Before the first release the checksums are empty, so resolution failing is expected.

let sdkVersion       = "0.0.0"
let checksumCore     = ""
let checksumPlayer   = ""
let checksumStreamer = ""

// MARK: -

let releaseBase = "https://github.com/shoplive/shoplive-sdk-ios/releases/download/v\(sdkVersion)"

let package = Package(
    name: "ShopliveSDK",
    platforms: [
        // The unified Player embeds the WebRTC engine in a single binary and the whole streaming
        // path is already on 15, so iOS 15 is the floor. (Deployment Target Guide 2026-07-20 §1/§7)
        // Dropping to iOS 13 is gated on the rtc-ios binary's min deployment target; lower this
        // value once that is confirmed.
        .iOS(.v15)
    ],
    products: [
        // ShopliveCore is deliberately not exposed as its own product. The Player and Streamer
        // products carry the Core binary, so integrators never add it separately.
        .library(
            name: "ShoplivePlayerSDK",
            targets: ["ShoplivePlayerSDK", "ShopliveCore"]
        ),
        .library(
            name: "ShopliveStreamerSDK",
            targets: ["ShopliveStreamerSDK", "ShopliveCore"]
        )
    ],
    targets: [
        // Shared core: auth, configuration, logging, networking (bundle id cloud.shoplive.core)
        .binaryTarget(
            name: "ShopliveCore",
            url: "\(releaseBase)/ShopliveCore.xcframework.zip",
            checksum: checksumCore
        ),
        // Playback: single module with both HLS and WebRTC engines, switched internally
        .binaryTarget(
            name: "ShoplivePlayerSDK",
            url: "\(releaseBase)/ShoplivePlayerSDK.xcframework.zip",
            checksum: checksumPlayer
        ),
        // Broadcasting: WebRTC ingest engine (phase 1)
        .binaryTarget(
            name: "ShopliveStreamerSDK",
            url: "\(releaseBase)/ShopliveStreamerSDK.xcframework.zip",
            checksum: checksumStreamer
        )
    ]
)
