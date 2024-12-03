// swift-tools-version: 6.0
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
            name: "AnimatedImage",
            dependencies: [
                "UpdateLink"
            ],
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "UpdateLink"
        ),
        .target(
            name: "AnimatedImageSwiftUI",
            dependencies: [
                "AnimatedImage"
            ],
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]
        ),
        .testTarget(
            name: "AnimatedImageTests",
            dependencies: ["AnimatedImage"]
        ),
    ]
)

/*
let warnConcurrency = "-warn-concurrency"
let enableActorDataRaceChecks = "-enable-actor-data-race-checks"
let swiftSettings: [SwiftSetting] = [
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0335-existential-any.md
    .enableUpcomingFeature("ExistentialAny"), // 5.8
    // resource_bundle_accessor.swiftなどが対応するまでは保留
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0409-access-level-on-imports.md
//    .enableExperimentalFeature("AccessLevelOnImport"), // 5.9
    .enableUpcomingFeature("InternalImportsByDefault"), // 6.0
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0440-debug-description-macro.md
    .enableExperimentalFeature("DebugDescriptionMacro"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0436-objc-implementation.md
    .enableExperimentalFeature("ObjCImplementation"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0432-noncopyable-switch.md
    .enableExperimentalFeature("BorrowingSwitch"),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0427-noncopyable-generics.md
    .enableExperimentalFeature("NoncopyableGenerics"),
    .unsafeFlags([
        warnConcurrency,
        enableActorDataRaceChecks,
    ]),
]

package.targets.forEach { target in
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(contentsOf: swiftSettings)
}
*/
