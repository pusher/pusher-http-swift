import Foundation

/// A summarised information record for an occupied channel.
public struct ChannelSummary: ChannelSummaryRecord, Decodable {

    // MARK: - Public properties

    public let name: String
    public let attributes: ChannelAttributes
    public let type: ChannelType
}
