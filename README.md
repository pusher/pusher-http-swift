# Pusher Channels Swift REST API Library

![Build Status](https://github.com/pusher/pusher-http-swift/workflows/CI/badge.svg)
[![Latest Release](https://img.shields.io/github/v/release/pusher/pusher-http-swift)](https://github.com/pusher/pusher-http-swift/releases)
[![API Docs](https://img.shields.io/badge/Docs-here!-lightgrey)](https://pusher.github.io/pusher-http-swift/)
[![Supported Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpusher%2Fpusher-http-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/pusher/pusher-http-swift)
[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fpusher%2Fpusher-http-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/pusher/pusher-http-swift)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![LICENSE](https://img.shields.io/github/license/pusher/pusher-http-swift)](https://github.com/pusher/pusher-http-swift/blob/main/LICENSE)

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
        .package(url: "https://github.com/pusher/pusher-http-swift.git",
                 .upToNextMajor(from: "0.1.0")),
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

This section describes how to configure and use this library to act as an interface to your Pusher Channels app via the Channels HTTP API.

**NOTES:**
- Certain initializers or methods can throw an error if invalid parameters are provided, or an operation fails for some reason. **The use of `try!` in the code examples shown below is for brevity and is not recommended for a production application.**

### Configuration

Use the credentials from your Pusher Channels application to create a new `Pusher` instance, which will act as your API client:

```swift
let pusher = Pusher(options: try! PusherClientOptions(appId: 123456,
                                                      key: "YOUR_APP_KEY",
                                                      secret: "YOUR_APP_SECRET",
                                                      encryptionMasterKey: "YOUR_BASE64_ENCODED_MASTER_KEY",
                                                      cluster: "YOUR_APP_CLUSTER"))
```
**NOTES:**
- See the discussion in [End to end encryption](#end-to-end-encryption) for details on how to generate a secure `encryptionMasterKey`.

### Triggering events

To trigger an event on one or more channels, use the `trigger(event:callback:)` method.

#### A single channel

```swift
let publicChannel = Channel(name: "my-channel", type: .public)
let publicEvent = try! Event(eventName: "my-event",
                             eventData: "hello world!",
                             channel: publicChannel)

self.pusher.trigger(event: publicEvent) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

#### Multiple channels

```swift
let publicChannelOne = Channel(name: "my-channel", type: .public)
let publicChannelTwo = Channel(name: "my-other-channel", type: .public)
let multichannelEvent = try! Event(eventName: "my-multichannel-event",
                                   eventData: "hello world!",
                                   channels: [publicChannelOne,
                                              publicChannelTwo])

self.pusher.trigger(event: publicEvent) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

#### Event batches

It's also possible to send multiple events with a single API call (max 10 events per call on multi-tenant clusters) using the `trigger(events:callback:)` method:

```swift
let publicChannelOne = Channel(name: "my-channel", type: .public)
let publicChannelTwo = Channel(name: "my-other-channel", type: .public)
let eventOne = try! Event(eventName: "my-event",
                          eventData: "hello world!",
                          channel: publicChannelOne)
let eventTwo = try! Event(eventName: "my-other-event",
                          eventData: "hello world, again!",
                          channel: publicChannelTwo)

self.pusher.trigger(events: [eventOne, eventTwo]]) { result in
    switch result {
        case .success(let channelInfoList):
            // Inspect `channelInfoList`
        case .failure(let error):
            // Handle error
    }
}
```

#### Excluding receipients

In some situations, you want to stop the client that broadcasts an event from receiving it. You can do this (by specifying its `socketId`)[https://pusher.com/docs/channels/server_api/excluding-event-recipients] when triggering an event:

```swift
let socketIdToExclude = "123.456"
let publicChannel = Channel(name: "my-channel", type: .public)
let excludedClientEvent = try! Event(eventName: "my-event",
                                     eventData: "hello world!",
                                     channel: publicChannel,
                                     socketId: socketIdToExclude)

self.pusher.trigger(event: excludedClientEvent) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

#### Fetching channel attributes on triggering events [[EXPERIMENTAL](https://pusher.com/docs/lab#experimental-program)]

It is possible to fetch attributes about the channel(s) that were triggered to with the `attributeOptions` parameter on `Event`. This works with both `trigger(…)` methods:

```swift
let publicChannel = Channel(name: "my-channel", type: .public)
let publicEvent = try! Event(eventName: "my-event",
                             eventData: "hello world!",
                             channel: publicChannel,
                             attributeOptions: [.subscriptionCount])

self.pusher.trigger(event: publicEvent) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

### Authenticating channel subscriptions

Users that attempt to subscribe to a private or presence channel must be first authenticated. An authentication token that can be returned to a user client that is attempting a subscription, which requires authentication with the server.

#### Private channels

To authenticate a user that is attempting to subscribe to a private channel, you can use the `authenticate(channel:socketId:callback:)` method:

```swift
let userSocketId = "123.456"
let privateChannel = Channel(name: "my-channel", type: .private)

self.pusher.authenticate(channel: privateChannel,
                         socketId: userSocketId) { result in
    switch result {
        case .success(let authToken):
            // Inspect `authToken`
        case .failure(let error):
            // Handle error
    }
}
```

#### Presence channels

To authenticate a user that is attempting to subscribe to a presence channel, you must provide a `userData` parameter to the same method:

```swift
let userData = PresenceUserAuthData(userId: "USER_ID", userInfo: ["name": "Joe Bloggs"])
let presenceChannel = Channel(name: "my-channel", type: .presence)

self.pusher.authenticate(channel: presenceChannel,
                         socketId: "USER_SOCKET_ID",
                         userData: userData) { result in
    switch result {
        case .success(let authToken):
            // Inspect `authToken`
        case .failure(let error):
            // Handle error
    }
}
```

### Verifying webhooks

This library provides a way to verify that a received webhook request is genuine and was received from Pusher. Since a webhook endpoint is accessible to the global internet, verifying that webhook request originated from Pusher is important. Valid webhooks contain special headers which contain a copy of your application key and a HMAC signature of the webhook payload (i.e. its body):

```swift
self.pusher.verifyWebhookRequest(receivedWebhookRequest) { result in
    switch result {
        case .success(let webhook):
            // Inspect `webhook`
        case .failure(let error):
            // Handle error
    }
}
```

### End to end encryption

This library supports end-to-end encryption of your private channels. This means that only you and your connected clients will be able to read your messages. Pusher cannot decrypt them. You can enable this feature by following these steps:

1. You should first set up private channels. This involves [creating an authentication endpoint on your server](https://pusher.com/docs/authenticating_users).

2. Next, generate your 32 byte master encryption key, encode it as Base-64 and pass it to the `PusherClientOptions` initializer. **This is secret and you should never share this with anyone, not even Pusher.**

```bash
openssl rand -base64 32
```

```swift
let options = try! PusherClientOptions(appId: 123456,
                                       key: "YOUR_APP_KEY",
                                       secret: "YOUR_APP_SECRET",
                                       encryptionMasterKey: "<MASTER KEY GENERATED BY PREVIOUS COMMAND>",
                                       cluster: "YOUR_APP_CLUSTER")
```

3. Channels where you wish to use end-to-end encryption should be of type `encrypted`.

4. Subscribe to these channels in your client, and you're done! You can verify it is working by checking out the debug console on the [https://dashboard.pusher.com/](dashboard) and seeing the scrambled ciphertext.

**Important note: This will **not** encrypt messages on channels that are not of type `encrypted`.**

**Limitation:** you cannot trigger a single event on multiple channels in a call to the `trigger(event:callback:)` method, e.g:

```swift
let publicChannel = Channel(name: "my-channel", type: .public)
let encryptedChannel = Channel(name: "my-other-channel", type: .encrypted)
let event = try! Event(eventName: "my-event",
                       eventData: "hello world!",
                       channels: [publicChannel, encryptedChannel])

self.pusher.trigger(event: event]) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

**Rationale:** the methods in this library map directly to individual Channels HTTP API requests. If we allowed triggering a single event on multiple channels (some encrypted, some unencrypted), then it would require two API requests: one where the event is encrypted to the encrypted channels, and one where the event is unencrypted for unencrypted channels.

### Application state queries

Information about the current state of your Channels application can be fetched using the library. This includes the state of occupied channels, and users subscribed to presence channels.

#### Fetch a list of occupied channels

A list of any occupied channels for your Channels application can be fetched using the `channels(withFilter:attributeOptions:callback:)` method:

```swift
// Fetching all occupied channels
self.pusher.channels { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}

// Fetching only occupied private channels
self.pusher.channels(withFilter: .private) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}

// Fetching all occupied presence channels (with user counts)
self.pusher.channels(withFilter: .presence,
                     attributeOptions: .userCount) { result in
    switch result {
        case .success(let channelSummaries):
            // Inspect `channelSummaries`
        case .failure(let error):
            // Handle error
    }
}
```

#### Fetch information about a channel

Information about a channel for your Channels application can be fetched using the `channelInfo(for:attributeOptions:callback:)` method:

```swift
// Fetch information for a public channel
let publicChannel = Channel(name: "my-channel", type: .public)
self.pusher.channelInfo(for: publicChannel) { result in
    switch result {
        case .success(let channelInfo):
            // Inspect `channelInfo`
        case .failure(let error):
            // Handle error
    }
}

// Fetch information for a private channel (with subscription count)
let privateChannel = Channel(name: "my-channel", type: .private)
self.pusher.channelInfo(for: privateChannel,
                        attributeOptions: [.subscriptionCount]) { result in
    switch result {
        case .success(let channelInfo):
            // Inspect `channelInfo`
        case .failure(let error):
            // Handle error
    }
}

// Fetch information for a presence channel (with user count)
let presenceChannel = Channel(name: "my-channel", type: .presence)
self.pusher.channelInfo(for: presenceChannel,
                        attributeOptions: [.userCount]) { result in
    switch result {
        case .success(let channelInfo):
            // Inspect `channelInfo`
        case .failure(let error):
            // Handle error
    }
}
```

**NOTES:**
- If the specified channel is not occupied (i.e. it has no subscribers), then the returned `ChannelInfo` object will not contain any attributes (regardless of if they were requested) and its `isOccupied` property will be set to `false`.

#### Fetch a list of users subscribed to a presence channel

A list of users subscribed to a presence channel for your Channels application can be fetched using the `users(for:callback:)` method:

```swift
let presenceChannel = Channel(name: "my-channel", type: .presence)
self.pusher.users(for: presenceChannel) { result in
    switch result {
        case .success(let users):
            // Inspect `users`
        case .failure(let error):
            // Handle error
    }
}
```

## Documentation

Full documentation of the library can be found in the [API docs](https://pusher.github.io/pusher-http-swift/).

## Reporting bugs and requesting features

Please ensure you use the relevant issue template when reporting a bug or requesting a new feature. Also please check first to see if there is an open issue that already covers your bug report or new feature request.

## License

The library is completely open source and released under the MIT license. See [LICENSE](https://github.com/pusher/pusher-http-swift/blob/main/LICENSE) for details if you want to use it in your own project(s).
