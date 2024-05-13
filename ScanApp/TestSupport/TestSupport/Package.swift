// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TestSupport",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TestSupport",
            targets: ["TestSupport"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/AliSoftware/OHHTTPStubs",
            .exact("9.1.0")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TestSupport",
            dependencies: [
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs"),
            ]
        ),
        .testTarget(
            name: "TestSupportTests",
            dependencies: ["TestSupport"]),
    ]
)
