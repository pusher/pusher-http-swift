import Foundation

/// A representation of the "get users for channel" HTTP API response.
struct GetUsersForChannelAPIResponse: Decodable {

    /// The users subscribed to a presence channel.
    let users: [User]
}
