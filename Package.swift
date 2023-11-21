// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GifKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "GifKit",
            targets: ["GifKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "GifKit",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "GifKitTests",
            dependencies: ["GifKit"]
        ),
    ]
)
