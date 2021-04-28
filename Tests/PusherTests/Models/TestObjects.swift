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

    static let encodedEventData = try! JSONEncoder().encode(eventData)

    // MARK: - Webhooks

    static let channelOccupiedWebhookRequest: URLRequest = {
        return webhookRequest(for: channelOccupiedWebhook)
    }()

    static let channelVacatedWebhookRequest: URLRequest = {
        return webhookRequest(for: channelVacatedWebhook)
    }()

    static let memberAddedWebhookRequest: URLRequest = {
        return webhookRequest(for: memberAddedWebhook)
    }()

    static let memberRemovedWebhookRequest: URLRequest = {
        return webhookRequest(for: memberRemovedWebhook)
    }()

    static let clientEventWebhookRequest: URLRequest = {
        return webhookRequest(for: clientEventWebhook)
    }()

    static let missingKeyHeaderWebhookRequest: URLRequest = {
        return webhookRequest(for: channelOccupiedWebhook,
                              pusherKeyHeaderValue: nil)
    }()

    static let invalidKeyHeaderWebhookRequest: URLRequest = {
        return webhookRequest(for: channelOccupiedWebhook,
                              pusherKeyHeaderValue: "invalid_key")
    }()

    static let missingSignatureHeaderWebhookRequest: URLRequest = {
        return webhookRequest(for: channelOccupiedWebhook,
                              pusherSignatureHeaderValue: nil)
    }()

    static let invalidSignatureHeaderWebhookRequest: URLRequest = {
        return webhookRequest(for: channelOccupiedWebhook,
                              pusherSignatureHeaderValue: "invalid_signature")
    }()

    static let missingBodyDataWebhookRequest: URLRequest = {
        return webhookRequest()
    }()

    // MARK: - Private methods and properties

    private static let channelOccupiedWebhook = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                        events: [WebhookEvent(eventType: .channelOccupied,
                                                                              channelName: "my-channel")])

    private static let channelVacatedWebhook = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                       events: [WebhookEvent(eventType: .channelVacated,
                                                                             channelName: "my-channel")])

    private static let memberAddedWebhook = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                    events: [WebhookEvent(eventType: .memberAdded,
                                                                          channelName: "presence-my-channel",
                                                                          userId: "user_1")])

    private static let memberRemovedWebhook = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                      events: [WebhookEvent(eventType: .memberRemoved,
                                                                            channelName: "presence-my-channel",
                                                                            userId: "user_1")])

    private static let clientEventWebhook = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                    events: [WebhookEvent(eventType: .clientEvent,
                                                                          channelName: "my-channel",
                                                                          eventName: "my-event",
                                                                          eventData: encodedEventData,
                                                                          socketId: "socket_1")])

    private static func webhookRequest(for webhook: Webhook? = nil,
                                       pusherKeyHeaderValue: String? = testKey,
                                       pusherSignatureHeaderValue: String? = testSecret) -> URLRequest {

        var request = URLRequest(url: URL(string: "https://google.com")!)
        if let webhook = webhook {
            request.httpBody = try? JSONEncoder().encode(webhook)
        }

        request.setValue(pusherKeyHeaderValue, forHTTPHeaderField: WebhookService.xPusherKeyHeader)

        if pusherSignatureHeaderValue != nil, request.httpBody != nil {
            let signature = Crypto.sha256HMAC(for: request.httpBody!,
                                              using: pusherSignatureHeaderValue!.toData()).hexEncodedString()
            request.setValue(signature, forHTTPHeaderField: WebhookService.xPusherSignatureHeader)
        }

        return request
    }
}
