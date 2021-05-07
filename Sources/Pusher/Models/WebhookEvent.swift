import Foundation

/// An event that is contained within a received `Webhook`.
public struct WebhookEvent: WebhookEventRecord {

    // The event type.
    public let eventType: WebhookEventType

    /// The channel name relating to the Webhook event.
    public let channelName: String

    /// The event name (only set if `eventType` is `clientEvent`).
    public let eventName: String?

    /// The event data (only set if `eventType` is `clientEvent`).
    public let eventData: Data?

    /// The identifier of the socket that sent the event (only set if `eventType` is `clientEvent`).
    public let socketId: String?

    /// The user identifier associated with the socket that sent the event (only set for presence channels).
    public let userId: String?

    enum CodingKeys: String, CodingKey {
        case eventType = "name"
        case channelName = "channel"
        case eventName = "event"
        case eventData = "data"
        case socketId = "socket_id"
        case userId = "user_id"
    }

    // MARK: - Lifecycle (used in Tests)

    init(eventType: WebhookEventType,
         channelName: String,
         eventName: String? = nil,
         eventData: Data? = nil,
         socketId: String? = nil,
         userId: String? = nil) {
        self.eventType = eventType
        self.channelName = channelName
        self.eventName = eventName
        self.eventData = eventData
        self.socketId = socketId
        self.userId = userId
    }

    // MARK: - Event data decryption

    /// Returns an `WebhookEvent` with decrypted `eventData` if `channelName` indicates
    /// the event occured on an encrypted channel.
    ///
    /// The event data ciphertext is decrypted using the received nonce and a shared secret which is
    /// a concatenation of the channel name and the `encryptionMasterKey` from `options`.
    /// - Parameter options: Configuration options used to managing the connection.
    /// - Throws: An `PusherError` if decrypting the `eventData` fails for some reason.
    /// - Returns: A copy of the receiver, but with decrypted `eventData`. If the `channel` is not
    ///            encrypted, the receiver will be returned unaltered.
    func decrypted(using options: PusherClientOptions) throws -> Self {
        guard let eventData = eventData, ChannelType(channelName: channelName) == .encrypted else {
            return self
        }

        let encryptedData = try JSONDecoder().decode(EncryptedData.self, from: eventData)
        let sharedSecretString = "\(channelName)\(options.encryptionMasterKey)"
        let sharedSecret = CryptoService.sha256Digest(data: sharedSecretString.toData())
        let decryptedEventData = try CryptoService.decrypt(data: Data(base64Encoded: encryptedData.ciphertext)!,
                                                           nonce: Data(base64Encoded: encryptedData.nonce)!,
                                                           key: sharedSecret)
        return WebhookEvent(eventType: eventType,
                            channelName: channelName,
                            eventName: eventName,
                            eventData: decryptedEventData,
                            socketId: socketId,
                            userId: userId)
    }
}
