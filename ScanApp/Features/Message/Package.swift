// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Message",
    platforms: [ .iOS(.v17) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Message",
            targets: ["Message"]),

        .library(
                name: "MessageMocks",
                targets: ["MessageMocks"]),
    ],
    dependencies: [
        .package(path: "./CoreUI"),
        .package(path: "./NetWork")

    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Message",
            dependencies: ["CoreUI",
                           "NetWork"
                          ],
            resources: [.process("Resources")]
        ),
        
        .target(
            name: "MessageMocks",
            dependencies: ["Message",
                          ],
            resources: [.process("Resources")]
        ),

        .testTarget(
            name: "MessageTests",
            dependencies: [
                "Message",
                "MessageMocks",
            ],
            resources: [.process("Resources")]
        ),
    ]
)
