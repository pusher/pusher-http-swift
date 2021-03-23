import Foundation

/// A summarised information record for an occupied channel.
public struct ChannelSummary: ChannelSummaryRecord, Decodable {

    // MARK - Public properties

    let name: String
    let subscriptionCount: UInt?
    let userCount: UInt?
    let type: ChannelType
}
