import Foundation

/// A summarised information record for an occupied channel.
public struct ChannelSummary: ChannelSummaryRecord {

    // MARK: - Public properties

    /// The channel.
    public let channel: Channel

    /// The fetched channel attributes.
    public let attributes: ChannelAttributes
}
