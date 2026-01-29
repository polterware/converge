// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// This Package.swift is used for centralized dependency management.
// The app itself is built and managed by Xcode.

import PackageDescription

let package = Package(
    name: "converge",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // No products defined - this package is used for dependency management
        // The app is built and managed by Xcode
    ],
    dependencies: [
        .package(
            url: "https://github.com/sparkle-project/Sparkle",
            from: "2.8.1"
        )
    ],
    targets: [
        // Dummy target required by Swift Package Manager
        // This target is not used - the app targets are defined in the Xcode project
        .target(
            name: "ConvergeDependencies",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/ConvergeDependencies"
        )
    ]
)
