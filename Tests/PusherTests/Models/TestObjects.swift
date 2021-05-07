import Foundation
@testable import Pusher

// swiftlint:disable force_try

struct TestObjects {

    // MARK: - SDK client for Tests

    struct Client {

        static let testAppId = 1070530
        static let testKey = "b5390e69136683c40d2d"
        static let testSecret = "24aaea961cfe1335f796"
        static let testMasterKey = "a7QyXV8eYrtJBehbuix68XCPO6+LrpnNNReWOkaXW7A="
        static let testCluster = "eu"

        // MARK: Shared client

        static let shared = Pusher(options: try! PusherClientOptions(appId: testAppId,
                                                                     key: testKey,
                                                                     secret: testSecret,
                                                                     encryptionMasterKey: testMasterKey,
                                                                     cluster: testCluster))
    }

    // MARK: - Client options

    struct ClientOptions {

        static let testAppId = 123456
        static let testKey = "auth_key"
        static let testSecret = "auth_secret"
        static let testEncryptionMasterKey = "hsRSqt4JEOd4bu2ww+F7e94BZsMBmELIUMHfhpTml2w="
        static let invalidEncryptionMasterKey = "invalid_master_key"
        static let testCluster = "eu"
        static let testCustomHost = "myhost.com"
        static let invalidPrefixCustomHost = "https://myhost.com"
        static let invalidSuffixCustomHost = "myhost.com/"
        static let testCustomPort = 3000

        // MARK: Test instances

        static let withCluster = try! PusherClientOptions(appId: testAppId,
                                                          key: testKey,
                                                          secret: testSecret,
                                                          encryptionMasterKey: testEncryptionMasterKey,
                                                          cluster: testCluster)

        static let withCustomHost = try! PusherClientOptions(appId: testAppId,
                                                             key: testKey,
                                                             secret: testSecret,
                                                             encryptionMasterKey: testEncryptionMasterKey,
                                                             host: testCustomHost)

        static let withCustomPort = try! PusherClientOptions(appId: testAppId,
                                                             key: testKey,
                                                             secret: testSecret,
                                                             encryptionMasterKey: testEncryptionMasterKey,
                                                             host: testCustomHost,
                                                             port: testCustomPort,
                                                             scheme: "https",
                                                             useTLS: false)

        static let withInvalidMasterKey = try! PusherClientOptions(appId: testAppId,
                                                                   key: testKey,
                                                                   secret: testSecret,
                                                                   encryptionMasterKey: invalidEncryptionMasterKey,
                                                                   cluster: testCluster)

        static let withInvalidPrefixHost = try! PusherClientOptions(appId: testAppId,
                                                                    key: testKey,
                                                                    secret: testSecret,
                                                                    encryptionMasterKey: invalidEncryptionMasterKey,
                                                                    host: invalidPrefixCustomHost)

        static let withInvalidSuffixHost = try! PusherClientOptions(appId: testAppId,
                                                                    key: testKey,
                                                                    secret: testSecret,
                                                                    encryptionMasterKey: invalidEncryptionMasterKey,
                                                                    host: invalidSuffixCustomHost)
    }

    // MARK: - Channels

    struct Channels {

        static let encrypted = Channel(name: "my-channel", type: .encrypted)

        static let presence = Channel(name: "my-channel", type: .presence)

        static let `private` = Channel(name: "my-channel", type: .private)

        static let `public` = Channel(name: "my-channel", type: .public)
    }

    // MARK: - Events

    struct Events {

        static let encrypted = try! Event(eventName: "my-event",
                                          eventData: Self.eventData,
                                          channel: TestObjects.Channels.encrypted)

        static let `private` = try! Event(eventName: "my-event",
                                          eventData: Self.eventData,
                                          channel: TestObjects.Channels.private)

        static let `public` = try! Event(eventName: "my-event",
                                         eventData: Self.eventData,
                                         channel: TestObjects.Channels.public)

        static let multichannel = try! Event(eventName: "my-multichannel-event",
                                             eventData: Self.eventData,
                                             channels: [TestObjects.Channels.private,
                                                        TestObjects.Channels.public])

        // MARK: Event payloads

        static let eventData = MockEventData(name: "Joe Bloggs",
                                             age: 28,
                                             job: "Software Engineer",
                                             metadata: ["id": 10])

        static let encodedEventData = try! JSONEncoder().encode(eventData)
    }

    // MARK: - Private and presence channel auth signatures

    struct AuthSignatures {

        static let testSocketId = "123.456"

        static let presenceAuthData = PresenceUserAuthData(userId: "user_1")

        static let presenceAuthDataWithUserInfo = PresenceUserAuthData(userId: "user_1",
                                                                       userInfo: ["name": "Joe Bloggs"])
    }

    // MARK: - Webhooks

    struct Webhooks {

        static let channelOccupiedWebhookRequest: URLRequest = {
            return webhookRequest(for: channelOccupied)
        }()

        static let channelVacatedWebhookRequest: URLRequest = {
            return webhookRequest(for: channelVacated)
        }()

        static let memberAddedWebhookRequest: URLRequest = {
            return webhookRequest(for: memberAdded)
        }()

        static let memberRemovedWebhookRequest: URLRequest = {
            return webhookRequest(for: memberRemoved)
        }()

        static let clientEventWebhookRequest: URLRequest = {
            return webhookRequest(for: clientEvent)
        }()

        static let missingKeyHeaderWebhookRequest: URLRequest = {
            return webhookRequest(for: channelOccupied,
                                  pusherKeyHeaderValue: nil)
        }()

        static let invalidKeyHeaderWebhookRequest: URLRequest = {
            return webhookRequest(for: channelOccupied,
                                  pusherKeyHeaderValue: "invalid_key")
        }()

        static let missingSignatureHeaderWebhookRequest: URLRequest = {
            return webhookRequest(for: channelOccupied,
                                  pusherSignatureHeaderValue: nil)
        }()

        static let invalidSignatureHeaderWebhookRequest: URLRequest = {
            return webhookRequest(for: channelOccupied,
                                  pusherSignatureHeaderValue: "invalid_signature")
        }()

        static let missingBodyDataWebhookRequest: URLRequest = {
            return webhookRequest()
        }()

        // MARK: Private methods and properties

        private static let channelOccupied = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                     events: [WebhookEvent(eventType: .channelOccupied,
                                                                           channelName: "my-channel")])

        private static let channelVacated = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                    events: [WebhookEvent(eventType: .channelVacated,
                                                                          channelName: "my-channel")])

        private static let memberAdded = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                 events: [WebhookEvent(eventType: .memberAdded,
                                                                       channelName: "presence-my-channel",
                                                                       userId: "user_1")])

        private static let memberRemoved = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                   events: [WebhookEvent(eventType: .memberRemoved,
                                                                         channelName: "presence-my-channel",
                                                                         userId: "user_1")])

        private static let clientEvent = Webhook(createdAt: Date(timeIntervalSince1970: 1619602993),
                                                 events: [WebhookEvent(eventType: .clientEvent,
                                                                       channelName: "my-channel",
                                                                       eventName: "my-event",
                                                                       eventData: TestObjects.Events.encodedEventData,
                                                                       socketId: "socket_1")])

        private static func webhookRequest(for webhook: Webhook? = nil,
                                           pusherKeyHeaderValue: String? = Client.testKey,
                                           pusherSignatureHeaderValue: String? = Client.testSecret) -> URLRequest {

            var request = URLRequest(url: URL(string: "https://google.com")!)
            if let webhook = webhook {
                request.httpBody = try? JSONEncoder().encode(webhook)
            }

            request.setValue(pusherKeyHeaderValue, forHTTPHeaderField: WebhookService.xPusherKeyHeader)

            if pusherSignatureHeaderValue != nil, request.httpBody != nil {
                let signature = CryptoService.sha256HMAC(for: request.httpBody!,
                                                         using: pusherSignatureHeaderValue!.toData()).hexEncodedString()
                request.setValue(signature, forHTTPHeaderField: WebhookService.xPusherSignatureHeader)
            }

            return request
        }
    }
}
