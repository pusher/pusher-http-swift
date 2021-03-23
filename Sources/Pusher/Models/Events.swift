import Foundation

/// An event to be published in the future.
public struct Event: PendingEvent, Encodable {

    let eventName: String
    let eventData: Data
    let channelNames: [String]?
    let channelName: String?
    let socketId: String?

    // MARK: - Encodable conformance

    enum CodingKeys: String, CodingKey {
        case eventName = "name"
        case eventData = "data"
        case channelNames = "channels"
        case channelName = "channel"
        case socketId = "socket_id"
    }
}

/// An event to be published in the future (as part of a batch).
public struct BatchEvent: PendingBatchEvent, Encodable {

    let eventName: String
    let eventData: Data
    let channelName: String
    let socketId: String?

    // MARK: - Encodable conformance

    enum CodingKeys: String, CodingKey {
        case eventName = "name"
        case eventData = "data"
        case channelName = "channel"
        case socketId = "socket_id"
    }
}
