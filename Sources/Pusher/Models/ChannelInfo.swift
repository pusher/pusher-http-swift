import Foundation

/// An information record for an occupied channel.
public struct ChannelInfo: ChannelInfoRecord, Decodable {

    public let isOccupied: Bool
    public let subscriptionCount: UInt?
    public let userCount: UInt?

    // MARK: - Decodable conformance

    enum CodingKeys: String, CodingKey {
        case isOccupied = "occupied"
        case subscriptionCount = "subscription_count"
        case userCount = "user_count"
    }
}
