// swift-tools-version: 5.9
// Shoplive iOS SDK — 국내(v1) 라인 XCFramework 배포 매니페스트.
//
// 각 릴리즈 태그에 첨부된 XCFramework zip 을 binary target 으로 가리킨다.
//
// 이 저장소는 두 라인을 함께 배포한다. main 은 3.x(통합 SDK), 이 브랜치(release/v1)는 1.x(국내)이며
// SwiftPM 은 태그에 담긴 매니페스트만 읽으므로 둘은 한 해석에 함께 등장하지 않는다.
// product·target 이름도 서로 겹치지 않는다.
//
// ⚠️ 이 브랜치는 main 에 머지하지 않는다. 머지하면 main 의 매니페스트가 1.x 로 덮여
// 3.x 배포가 깨진다. PR 을 여는 것은 리뷰 목적에 한한다.
//
// 숏폼·숏폼 Editor 는 이 매니페스트에 없다. shoplive/shortform-ios 와 shoplive/shortform-editor-ios 에서 받는다.
//
// Common(ShopliveSDKCommon · ShopliveAPI)은 이 매니페스트가 아니라 shoplive/common-ios 패키지가 싣는다(1.9.1~).
// 라이브 1.x · 숏폼 · 숏폼 에디터가 같은 common-ios 를 의존으로 선언해야 SwiftPM 이 Common 을 한 번만 해석하고,
// 라이브 3.x(main) 고객도 숏폼을 함께 넣을 수 있다(같은 shoplive-sdk-ios 를 두 버전으로 선언하지 않게 된다).

import PackageDescription

// MARK: - Release-managed
// 아래 값은 scripts/release.sh 가 덮어쓴다. 손으로 고치지 않는다.
// commonVersion 은 shoplive/common-ios 의 태그다 — release.sh 의 COMMON_VERSION 으로 바꾼다(기본 = 릴리스 버전).

let sdkVersion     = "1.9.0"
let checksumPlayer = "d31f0f6837d00b01f0532b9dd1200df3e59b1c15ec44fcb97ce7a80984a2a199"
let commonVersion  = "1.9.0"

// MARK: -

let releaseBase = "https://github.com/shoplive/shoplive-sdk-ios/releases/download/\(sdkVersion)"

let package = Package(
    name: "ShopliveSDK",
    platforms: [
        // 1.9.0 에서 Xcode 27 대응으로 11 에서 올라왔다.
        .iOS(.v15)
    ],
    products: [
        // 라이브 플레이어 · PIP. Common(common-ios)이 함께 해석·링크된다.
        // 1.9.0 의 `ShopliveSDKCommon` product 는 common-ios 로 옮겼다:
        //   .product(name: "ShopliveSDKCommon", package: "common-ios")
        .library(
            name: "ShopLiveSDK",
            targets: ["ShopLiveSDK", "ShopLiveSDKDependencies"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/shoplive/common-ios", exact: Version(stringLiteral: commonVersion))
    ],
    targets: [
        .binaryTarget(
            name: "ShopLiveSDK",
            url: "\(releaseBase)/ShopLiveSDK.xcframework.zip",
            checksum: checksumPlayer
        ),
        // 링크 전용 — binaryTarget 은 다른 패키지 product 에 의존할 수 없어 이 타깃이 Common 을 끌어온다.
        .target(
            name: "ShopLiveSDKDependencies",
            dependencies: [
                .product(name: "ShopliveSDKCommon", package: "common-ios")
            ],
            path: "Sources/ShopLiveSDKDependencies"
        )
    ]
)
