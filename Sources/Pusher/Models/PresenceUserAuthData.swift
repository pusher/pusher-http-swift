import AnyCodable
import Foundation

/// User data required when generating an `AuthToken` for a subscription attempt to a presence channel.
public struct PresenceUserAuthData: Encodable {

    /// The user identifier.
    public let userId: String

    /// Optional additional user data to send as part of a generated `AuthToken`.
    public let userInfo: [String: AnyEncodable]?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userInfo = "user_info"
    }

    // MARK: Lifecycle

    /// Creates an instance of `PresenceUserAuthData` for use when generating an `AuthToken`.
    /// - Parameter userId: The user identifier.
    /// - Parameter userInfo: Optional additional user data to send as part of a generated `AuthToken`.
    public init(userId: String, userInfo: [String: AnyEncodable]? = nil) {
        self.userId = userId
        self.userInfo = userInfo
    }
}
