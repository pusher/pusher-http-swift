import Foundation

/// An information record for a specific event.
protocol EventInfoRecord {

    /// The event name.
    var eventName: String { get }

    /// The event data.
    var eventData: Data { get }

    /// The connection to which the event will not be sent.
    var socketId: String? { get }
}

/// An event to be published in the future.
protocol PendingEvent: EventInfoRecord {

    /// The channels to which the event will be sent (if publishing to multiple channels).
    var channelNames: [String]? { get }

    /// The channel to which the event will be sent (if publishing to a single channel).
    var channelName: String? { get }
}

/// An event to be published in the future (as part of a batch).
protocol PendingBatchEvent: EventInfoRecord {

    /// The channel to which the event will be sent.
    var channelName: String { get }
}
