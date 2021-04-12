import Foundation

/// An attribute of an occupied channel.
public struct ChannelAttributes: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The number of distinct users that are currently subscribed.
    public static let userCount = ChannelAttributes(rawValue: 1 << 0)

    /// The number of all connections currently subscribed.
    public static let subscriptionCount = ChannelAttributes(rawValue: 1 << 1)

    /// All available attributes for the occupied channel.
    public static let all: ChannelAttributes = [.userCount, .subscriptionCount]
}

extension ChannelAttributes {

    /// An array of `URLQueryItem` that can be used when requesting additional attributes of occupied channels.
    var queryItems: [URLQueryItem] {
        var queryItems = [URLQueryItem]()

        if self.contains(.all) {
            queryItems = [URLQueryItem(name: "info", value: "user_count,subscription_count")]
        } else if self.contains(.userCount) {
            queryItems = [URLQueryItem(name: "info", value: "user_count")]
        } else if self.contains(.subscriptionCount) {
            queryItems = [URLQueryItem(name: "info", value: "subscription_count")]
        }

        return queryItems
    }
}
