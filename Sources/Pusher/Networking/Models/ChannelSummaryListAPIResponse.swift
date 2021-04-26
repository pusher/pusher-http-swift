import Foundation

// swiftlint:disable nesting

/// The HTTP API response returning a list of channel summaries.
struct ChannelSummaryListAPIResponse: Decodable {

    /// A dictionary representation of `ChannelAttributes` keyed by channel name.
    typealias ChannelAttributesDictionary = [String: ChannelAttributes]

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
        guard let attributesDict = try container.decodeIfPresent(ChannelAttributesDictionary.self,
                                                                forKey: .summaries) else {
            self.channelSummaryList = []
            return
        }

        self.channelSummaryList = attributesDict.map { (name: String, attributes: ChannelAttributes) -> ChannelSummary in
            return ChannelSummary(name: name,
                                  attributes: attributes,
                                  type: ChannelType(channelName: name))
        }
    }
}
