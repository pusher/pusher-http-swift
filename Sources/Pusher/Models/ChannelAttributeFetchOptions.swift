import Foundation

/// Attributes of an occupied channel that can be fetched from the Pusher HTTP API.
public struct ChannelAttributeFetchOptions: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The number of distinct users that are currently subscribed.
    public static let userCount = Self(rawValue: 1 << 0)

    /// The number of all connections currently subscribed.
    public static let subscriptionCount = Self(rawValue: 1 << 1)

    /// All available attributes for the occupied channel.
    public static let all: Self = [.userCount, .subscriptionCount]
}

extension ChannelAttributeFetchOptions {

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
