// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimatedImage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "AnimatedImage",
            targets: ["AnimatedImage"]
        ),
        .library(
            name: "AnimatedImageSwiftUI",
            targets: ["AnimatedImageSwiftUI"]
        )
    ],
    targets: [
        .target(
            name: "AnimatedImage"
        ),
        .target(
            name: "AnimatedImageSwiftUI",
            dependencies: [
                "AnimatedImage"
            ]
        ),
        .testTarget(
            name: "AnimatedImageTests",
            dependencies: ["AnimatedImage"]
        ),
    ]
)
