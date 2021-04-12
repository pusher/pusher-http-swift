import Foundation

/// A summarised information record for an occupied channel.
public struct ChannelSummary: ChannelSummaryRecord, Decodable {

    // MARK: - Public properties

    public let name: String
    public let subscriptionCount: UInt?
    public let userCount: UInt?
    public let type: ChannelType
}
