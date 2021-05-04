import Foundation

/// An event to trigger on a specific channel (or multiple channels).
public struct Event: EventInfoRecord, Encodable {

    public let channels: [Channel]?
    public let channel: Channel?
    public let eventName: String

    /// This is the `Data` representation of the original `eventData` parameter of the `init` methods.
    /// The data will be encrypted if a `channel` is set and its `ChannelType` is `.encrypted`.
    public let eventData: Data
    public let socketId: String?

    /// The channel attributes to fetch that will be present in the API response.
    let attributeOptions: ChannelAttributeFetchOptions

    // MARK: - Encodable conformance

    enum CodingKeys: String, CodingKey {
        case channels
        case channel
        case eventName = "name"
        case eventData = "data"
        case socketId = "socket_id"
        case attributeOptions = "info"
    }

    // MARK: - Lifecycle

    /// Creates an `Event` which will be triggered on a specific `Channel`.
    /// - Parameters:
    ///   - eventName: The name of the event.
    ///   - eventData: An event data object, whose type must conform to `Encodable`.
    ///   - channel: The `Channel` on which to trigger the `Event`.
    ///   - socketId: A connection to which the event will not be sent.
    /// - Throws: An `PusherError` if encoding the `eventData` fails for some reason.
    init<EventData: Encodable>(eventName: String,
                               eventData: EventData,
                               channel: Channel,
                               socketId: String? = nil,
                               attributeOptions: ChannelAttributeFetchOptions = []) throws {
        self.channel = channel
        self.channels = nil
        self.eventName = eventName
        self.eventData = try Self.encodeEventData(eventData)
        self.socketId = socketId
        self.attributeOptions = attributeOptions
    }

    /// Creates an `Event` which will be triggered on multiple `Channel`s.
    /// - Parameters:
    ///   - eventName: The name of the event.
    ///   - eventData: An event data object, whose type must conform to `Encodable`.
    ///   - channels: An array of `Channel`s on which to trigger the `Event`.
    ///   - socketId: A connection to which the event will not be sent.
    /// - Throws: An `PusherError` if encoding the `eventData` fails for some reason,
    ///           or if `channels` contains any encrypted channels.
    init<EventData: Encodable>(eventName: String,
                               eventData: EventData,
                               channels: [Channel],
                               socketId: String? = nil,
                               attributeOptions: ChannelAttributeFetchOptions = []) throws {

        // Throw an error if `channels` contains any encrypted channels
        // (Triggering an event on multiple channels is not allowed if any are encrypted).
        let containsEncryptedChannels = channels.contains { $0.type == .encrypted }
        guard !containsEncryptedChannels else {
            let reason = "Cannot trigger an event on multiple channels if any of them are encrypted."
            throw PusherError.invalidConfiguration(reason: reason)
        }

        self.channel = nil
        self.channels = channels
        self.eventName = eventName
        self.eventData = try Self.encodeEventData(eventData)
        self.socketId = socketId
        self.attributeOptions = attributeOptions
    }

    // MARK: - Custom Encodable conformance

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(eventName, forKey: .eventName)

        // This custom `encode(to:)` implementation is neccessary since
        // event data is expected as a `String` rather than as a JSON object
        let eventDataString = eventData.toString()
        try container.encode(eventDataString, forKey: .eventData)

        try container.encode(channels?.map { $0.internalName }, forKey: .channels)
        try container.encode(channel?.internalName, forKey: .channel)
        try container.encode(socketId, forKey: .socketId)
        if !attributeOptions.description.isEmpty {
            try container.encode(attributeOptions.description, forKey: .attributeOptions)
        }
    }

    // MARK: - Event data encryption

    /// Returns an `Event` with encrypted `eventData` if a `channel` is set
    /// and its `ChannelType` is `.encrypted`.
    ///
    /// The event data is encrypted using a random nonce and a shared secret which is
    /// a concatenation of the channel name and the `encryptionMasterKeyBase64` from `options`.
    ///
    /// If the provided `channel` is not an encrypted (or multiple `channels` are provided instead),
    /// then the receiver is returned unaltered.
    /// - Parameter options: Configuration options used to managing the connection.
    /// - Throws: An `PusherError` if encrypting the `eventData` fails for some reason.
    /// - Returns: A copy of the receiver, but with encrypted `eventData`. If the `channel` is not
    ///            encrypted, the receiver will be returned unaltered.
    func encrypted(using options: PusherClientOptions) throws -> Self {

        guard let channel = channel, channel.type == .encrypted else {
            return self
        }

        do {
            let eventNonce = try CryptoService.secureRandomData(count: 24)
            let sharedSecretString = "\(channel.internalName)\(options.encryptionMasterKeyBase64)"
            let sharedSecret = CryptoService.sha256Digest(data: sharedSecretString.toData())
            let eventCiphertext = try CryptoService.encrypt(data: eventData,
                                                            nonce: eventNonce,
                                                            key: sharedSecret)
            let encryptedEvent = EncryptedData(nonceData: eventNonce,
                                               ciphertextData: eventCiphertext)
            let encryptedEventData = try Self.encodeEventData(encryptedEvent)

            return try Event(eventName: eventName, eventData: encryptedEventData, channel: channel)
        } catch {
            throw PusherError(from: error)
        }
    }

    // MARK: - Private methods

    /// Encodes event data to its `Data` representation.
    ///
    /// If `eventData` is already encoded as `Data`, it is returned unaltered.
    /// - Parameter eventData: The event data, which conforms to `Encodable`.
    /// - Throws: A `PusherError` if the encoding operation fails for some reason.
    /// - Returns: The event data, encoded as `Data`.
    private static func encodeEventData<EventData: Encodable>(_ eventData: EventData) throws -> Data {

        if let dataEncodedEventData =  eventData as? Data {
            return dataEncodedEventData
        }

        return try JSONEncoder().encode(eventData)
    }
}
