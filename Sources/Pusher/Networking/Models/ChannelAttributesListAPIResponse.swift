import Foundation

// swiftlint:disable nesting

/// The HTTP API response returning a list of channel attributes.
struct ChannelAttributesListAPIResponse: Decodable {

    /// Channel attributes (e.g. `["user_count": 42]`).
    struct ChannelAttributes: SubscriptionCountable, UserCountable, Decodable {
        var subscriptionCount: UInt?
        var userCount: UInt?

        // MARK: - Decodable conformance

        enum CodingKeys: String, CodingKey {
            case subscriptionCount = "subscription_count"
            case userCount = "user_count"
        }
    }

    // MARK: - Properties

    /// An array of `ChannelInfo` for any occupied channels.
    let channelInfoList: [ChannelInfo]

    // MARK: - Decodable conformance

    enum CodingKeys: String, CodingKey {
        case attributes = "batch"
    }

    // MARK: - Custom Decodable initializer

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let attributesList = try container.decodeIfPresent([ChannelAttributes].self,
                                                                 forKey: .attributes) else {
            self.channelInfoList = []
            return
        }

        self.channelInfoList = attributesList.map { attributes -> ChannelInfo in
            return ChannelInfo(isOccupied: (attributes.subscriptionCount ?? 0 > 0 || attributes.userCount ?? 0 > 0),
                               subscriptionCount: attributes.subscriptionCount,
                               userCount: attributes.userCount)
        }
    }
}
