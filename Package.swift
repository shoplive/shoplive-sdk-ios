// swift-tools-version: 5.9
// Shoplive iOS SDK — 국내(v1) 라인 XCFramework 배포 매니페스트.
//
// 각 릴리즈 태그에 첨부된 XCFramework zip 을 binary target 으로 가리킨다.
//
// 이 저장소는 두 라인을 함께 배포한다. main 은 3.x(통합 SDK), 이 브랜치는 1.x(국내)이며
// SwiftPM 은 태그에 담긴 매니페스트만 읽으므로 둘은 한 해석에 함께 등장하지 않는다.
// product·target 이름도 서로 겹치지 않는다.
//
// ⚠️ 이 브랜치는 main 에 머지하지 않는다. 머지하면 main 의 매니페스트가 1.x 로 덮여
// 3.x 배포가 깨진다. PR 을 여는 것은 리뷰 목적에 한한다.
//
// 숏폼·숏폼 Editor 는 이 매니페스트에 없다. 기존대로 shoplive/shortform-ios 와
// shoplive/shortform-editor-ios 에서 받는다. 두 모듈은 1.8.7(matrix-sdk-ios 557a45d9c)
// 에서 Tuist 프로젝트 정의가 제거돼 현재 빌드 경로가 없고, 이번 릴리즈의 대상이 아니다.

import PackageDescription

// MARK: - Release-managed
// 아래 네 값은 scripts/release.sh 가 덮어쓴다. 손으로 고치지 않는다.
// 첫 릴리즈 전에는 checksum 이 비어 있으므로 해석이 실패하는 것이 정상이다.

let sdkVersion     = "0.0.0"
let checksumPlayer = ""
let checksumCommon = ""
let checksumAPI    = ""

// MARK: -

let releaseBase = "https://github.com/shoplive/shoplive-sdk-ios/releases/download/\(sdkVersion)"

let package = Package(
    name: "ShopliveSDK",
    platforms: [
        // 1.9.0 에서 Xcode 27 대응으로 11 에서 올라왔다.
        .iOS(.v15)
    ],
    products: [
        // 라이브 플레이어 · PIP
        .library(
            name: "ShopLiveSDK",
            targets: ["ShopLiveSDK"]
        ),
        // 인증 · 사용자 설정 · 공통 API.
        // ShopliveAPI 는 독립 product 가 아니라 Common 과 한 묶음으로 나간다 — 고객이
        // 따로 추가할 것이 없도록 product 가 아닌 target 으로 싣는다.
        .library(
            name: "ShopliveSDKCommon",
            targets: ["ShopliveSDKCommon", "ShopliveAPI"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ShopLiveSDK",
            url: "\(releaseBase)/ShopLiveSDK.xcframework.zip",
            checksum: checksumPlayer
        ),
        .binaryTarget(
            name: "ShopliveSDKCommon",
            url: "\(releaseBase)/ShopliveSDKCommon.xcframework.zip",
            checksum: checksumCommon
        ),
        .binaryTarget(
            name: "ShopliveAPI",
            url: "\(releaseBase)/ShopliveAPI.xcframework.zip",
            checksum: checksumAPI
        )
    ]
)
