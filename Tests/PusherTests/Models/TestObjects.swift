import Foundation
@testable import Pusher

// swiftlint:disable force_try

struct TestObjects {

    // MARK: - SDK client

    private static let testKey = "b5390e69136683c40d2d"
    private static let testSecret = "24aaea961cfe1335f796"
    private static let testCluster = "eu"
    private static let testMasterKey = "a7QyXV8eYrtJBehbuix68XCPO6+LrpnNNReWOkaXW7A="
    static let pusher = Pusher(options: PusherClientOptions(appId: 1070530,
                                                            key: testKey,
                                                            secret: testSecret,
                                                            useTLS: true,
                                                            host: "api-eu.pusher.com",
                                                            cluster: testCluster,
                                                            port: 443,
                                                            scheme: "https",
                                                            httpProxy: "",
                                                            encryptionMasterKeyBase64: testMasterKey))

    // MARK: - Channels

    static let encryptedChannel = Channel(name: "my-channel", type: .encrypted)
    static let presenceChannel = Channel(name: "my-channel", type: .presence)
    static let privateChannel = Channel(name: "my-channel", type: .private)
    static let publicChannel = Channel(name: "my-channel", type: .public)

    // MARK: - Single channel events

    static let encryptedEvent = try! Event(eventName: "my-event",
                                           eventData: Self.eventData,
                                           channel: Self.encryptedChannel)

    static let privateEvent = try! Event(eventName: "my-event",
                                        eventData: Self.eventData,
                                        channel: Self.privateChannel)

    static let publicEvent = try! Event(eventName: "my-event",
                                        eventData: Self.eventData,
                                        channel: Self.publicChannel)

    // MARK: - Multi-channel events

    static let multichannelEvent = try! Event(eventName: "my-multichannel-event",
                                              eventData: Self.eventData,
                                              channels: [Self.privateChannel,
                                                         Self.publicChannel])

    // MARK: - Event payloads

    static let eventData = MockEventData(name: "Joe Bloggs",
                                         age: 28,
                                         job: "Software Engineer")
}
