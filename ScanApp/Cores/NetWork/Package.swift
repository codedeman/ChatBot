// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetWork",
    platforms: [ .iOS(.v17) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetWork",
            targets: ["NetWork"]),
    ],
    dependencies: [
        .package(path: "../../Foundation/Logger"),
        .package(path: "../../TestSupport/TestSupport"),

    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetWork",
            dependencies: [
                "TestSupport",
                .product(name: "Logger", package: "Logger"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NetWorkTests",
            dependencies: ["NetWork"],
            resources: [.process("Resources")]
        ),


    ]
)
