// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pusher",
    platforms: [.iOS("13.0"),
                .macOS("10.15")],
    products: [
        .library(
            name: "Pusher",
            targets: ["Pusher"])
    ],
    dependencies: [
        // Source code linting
        .package(url: "https://github.com/realm/SwiftLint",
                 .upToNextMajor(from: "0.43.1")),
        // Simple REST API client implementation with 'Codable' types
        .package(url: "https://github.com/danielrbrowne/APIota",
                 .upToNextMajor(from: "0.1.3")),
        // Open-source implementation of Apple's `CryptoKit`
        // (Allows for crypto on Linux, and calls CryptoKit directly on Apple platforms)
        .package(url: "https://github.com/apple/swift-crypto",
                 .upToNextMajor(from: "1.1.6")),
        // Swift wrapper for TweetNaCl crypto functionality
        .package(name: "TweetNacl",
                 url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap",
                 .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "Pusher",
            dependencies: [
                "APIota",
                .product(name: "Crypto", package: "swift-crypto"),
                "TweetNacl"
            ]),
        .testTarget(
            name: "PusherTests",
            dependencies: ["Pusher"])
    ]
)
