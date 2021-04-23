import Foundation

// swiftlint:disable nesting

/// The HTTP API response returning a list of channel summaries.
struct ChannelSummaryListAPIResponse: Decodable {

    /// A JSON dictionary representation of channel summaries.
    typealias ChannelSummaryListJSON = [String: ChannelAttributes]

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

    /// An array of `ChannelSummary` for any occupied channels.
    let channelSummaryList: [ChannelSummary]

    // MARK: - Decodable conformance

    enum CodingKeys: String, CodingKey {
        case summaries = "channels"
    }

    // MARK: - Custom Decodable initializer

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let summariesJSON = try container.decodeIfPresent(ChannelSummaryListJSON.self,
                                                                forKey: .summaries) else {
            self.channelSummaryList = []
            return
        }

        self.channelSummaryList = summariesJSON.map { (channelName: String, attributes: ChannelAttributes) -> ChannelSummary in
            return ChannelSummary(name: channelName,
                                  subscriptionCount: attributes.subscriptionCount,
                                  userCount: attributes.userCount,
                                  type: ChannelType(channelName: channelName))
        }
    }
}
