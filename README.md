# Pusher Channels Swift REST API Library

![Build Status](https://github.com/pusher/pusher-http-swift/workflows/CI/badge.svg)
[![Latest Release](https://img.shields.io/github/v/release/pusher/pusher-http-swift)](https://github.com/pusher/pusher-http-swift/releases)
[![API Docs](https://img.shields.io/badge/Docs-here!-lightgrey)](https://pusher.github.io/pusher-http-swift/)
[![Supported Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpusher%2Fpusher-http-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pusher/pusher-http-swift)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpusher%2Fpusher-http-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pusher/pusher-http-swift)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![LICENSE](https://img.shields.io/github/license/pusher/pusher-http-swift)](https://github.com/pusher/pusher-http-swift/blob/master/LICENSE)

A Swift library for interacting with the [Pusher Channels HTTP API](https://pusher.com/docs/channels/library_auth_reference/rest-api).

Register for a [Pusher](https://pusher.com) account, set up a Channels app and use the app credentials app as shown below.

- [Supported platforms](#supported-platforms)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Reporting bugs and requesting features](#reporting-bugs-and-requesting-features)
- [License](#license)

## Supported platforms

- Swift 5.3 and above
- Xcode 12.0 and above

### Deployment targets

- iOS 13.0 and above
- macOS 10.15 and above
- tvOS 13.0 and above

## Installation

To integrate the library into your project using [Swift Package Manager](https://swift.org/package-manager/), you can add the library as a dependency in Xcode – see the [docs](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app). The package repository URL is:

```bash
https://github.com/pusher/pusher-http-swift.git
```

Alternatively, you can add the library as a dependency in your `Package.swift` file. For example:

```swift
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "YourPackage",
    products: [
        .library(
            name: "YourPackage",
            targets: ["YourPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pusher/pusher-http-swift.git", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: ["Pusher"]),
    ]
)
```

You will then need to include an `import Pusher` statement in any source files where you wish to use the library.

## Usage

### Configuration

### Triggering events

### Authenticating channel subscriptions

### Verifying webhooks

### End to end encryption

### Application state queries

## Documentation

Full documentation of the library can be found in the [API docs](https://pusher.github.io/pusher-http-swift/).

## Reporting bugs and requesting features

Please ensure you use the relevant issue template when reporting a bug or requesting a new feature. Also please check first to see if there is an open issue that already covers your bug report or new feature request.

## License

The library is completely open source and released under the MIT license. See [LICENSE](https://github.com/pusher/pusher-http-swift/blob/master/LICENSE) for details if you want to use it in your own project(s).
