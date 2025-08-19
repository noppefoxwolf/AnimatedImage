// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnimatedImage",
    platforms: [
        .iOS(.v16),
        .visionOS(.v1),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "AnimatedImage",
            targets: ["AnimatedImage"]
        )
    ],
    targets: [
        .target(
            name: "AnimatedImage",
            dependencies: [
                "AnimatedImageCore",
                .target(
                    name: "_UIKit_AnimatedImage",
                    condition: .when(platforms: [.iOS, .visionOS, .macCatalyst])
                ),
                .target(name: "_AppKit_AnimatedImage", condition: .when(platforms: [.macOS])),
                "_SwiftUI_AnimatedImage",
            ],
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "AnimatedImageCore"
        ),
        .target(
            name: "UpdateLink"
        ),
        .target(
            name: "_UIKit_AnimatedImage",
            dependencies: [
                "UpdateLink",
                "AnimatedImageCore",
            ]
        ),
        .target(
            name: "_AppKit_AnimatedImage",
            dependencies: [
                "UpdateLink",
                "AnimatedImageCore",
            ]
        ),
        .target(
            name: "_SwiftUI_AnimatedImage",
            dependencies: [
                .target(
                    name: "_UIKit_AnimatedImage",
                    condition: .when(platforms: [.iOS, .visionOS, .macCatalyst])
                ),
                .target(name: "_AppKit_AnimatedImage", condition: .when(platforms: [.macOS])),
            ]
        ),
        .testTarget(
            name: "AnimatedImageTests",
            dependencies: ["AnimatedImage"]
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    // https://github.com/swiftlang/swift/blob/3d3331f1c625fb22c60f361ac06caf06138efc69/include/swift/Basic/Features.def#L278
    // Swift 7
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}

