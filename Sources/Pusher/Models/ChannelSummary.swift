import Foundation

/// A summarised information record for an occupied channel.
public struct ChannelSummary: ChannelSummaryRecord, Decodable {

    // MARK: - Public properties

    /// The channel name.
    public let name: String

    /// The fetched channel attributes.
    public let attributes: ChannelAttributes

    /// The channel type.
    public let type: ChannelType
}
