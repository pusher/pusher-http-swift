import Foundation

/// User data required when generating an `AuthToken` for a subscription attempt to a presence channel.
public struct PresenceUserAuthData: Encodable {

    /// The user identifier.
    public let userId: String

    /// The `Data` representation of any additional user data to send as part of a generated `AuthToken`.
    public let userInfo: Data?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userInfo = "user_info"
    }

    // MARK: Lifecycle

    /// Creates a `PresenceUserAuthData` without any additional user data provided.
    /// - Parameter userId: The user identifier.
    init(userId: String) {
        self.userId = userId
        self.userInfo = nil
    }

    /// Creates a `PresenceUserAuthData` with some additional user data provided.
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - userInfo: additional user data to send as part of a generated `AuthToken`.
    /// - Throws: A `PusherError` if encoding the `userInfo` failed for some reason.
    init<T: Encodable>(userId: String, userInfo: T) throws {
        self.userId = userId
        do {
            self.userInfo = try JSONEncoder().encode(userInfo)
        } catch {
            throw PusherError(from: error)
        }
    }

    // MARK: - Custom Encodable conformance

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(userId, forKey: .userId)

        // This custom `encode(to:)` implementation is neccessary since
        // user info is expected as a `String` rather than as a JSON object
        let userInfoString = userInfo?.toString()
        try container.encodeIfPresent(userInfoString, forKey: .userInfo)
    }
}
