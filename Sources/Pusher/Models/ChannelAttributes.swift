import Foundation

/// Channel attributes that can be fetched depending on the `ChannelAttributeFetchOptions`
/// provided to a top-level API method (see `Pusher.swift`).
public struct ChannelAttributes: SubscriptionCountable, UserCountable, Decodable {

    public let subscriptionCount: UInt?

    public let userCount: UInt?

    // MARK: - Decodable conformance

    enum CodingKeys: String, CodingKey {
        case subscriptionCount = "subscription_count"
        case userCount = "user_count"
    }
}
