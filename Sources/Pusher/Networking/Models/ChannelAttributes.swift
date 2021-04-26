import Foundation

/// Channel attributes that can be fetched depending on the `ChannelAttributeFetchOptions`
/// provided to a top-level API method (see `Pusher.swift`).
struct ChannelAttributes: SubscriptionCountable, UserCountable, Decodable {
    var subscriptionCount: UInt?
    var userCount: UInt?

    // MARK: - Decodable conformance

    enum CodingKeys: String, CodingKey {
        case subscriptionCount = "subscription_count"
        case userCount = "user_count"
    }
}
