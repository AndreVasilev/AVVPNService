// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AVVPNService",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "AVVPNService",
            targets: ["AVVPNService"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AVVPNService",
            dependencies: []),
        .testTarget(
            name: "AVVPNServiceTests",
            dependencies: ["AVVPNService"]),
    ],
    swiftLanguageVersions: [.v5]
)
