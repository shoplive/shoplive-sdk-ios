// 링크 전용 타깃.
//
// binaryTarget 은 다른 패키지의 product 에 의존을 걸 수 없다. ShopLiveSDK 바이너리가 런타임에 링크하는
// ShopliveSDKCommon(common-ios)을 ShopLiveSDK product 와 함께 해석·링크되게 하려고 이 소스 타깃을 product 에 같이 싣는다.
// 고객 코드가 이 모듈을 import 할 일은 없다.
import ShopliveSDKCommon
