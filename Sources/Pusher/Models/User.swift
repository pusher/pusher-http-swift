import Foundation

/// An information record for a specific user currently subscribed to a presence channel.
public struct User: UserInfoRecord, Decodable {

    public let id: String
}
