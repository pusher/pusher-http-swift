import Foundation

/// Encapsulates an authentication signature that can be used when users
/// subscribe to private or presence channels.
///
/// The authentication token will contain any `userData` that was provided during
/// the signing request. In the case of encrypted channels, it will also
/// contain a base-64 encoded `sharedSecret`.
public struct AuthenticationToken: Codable {

    /// The authentication signature for the channel subscription attempt.
    public let signature: String

    /// The `String` representation of any `PresenceUserData` that was provided
    /// during the signing request.
    public let userData: String?

    /// A base-64 encoded shared secret `String` used for decryption.
    /// (This is only generated for a subscription attempt on an encrypted channel).
    public let sharedSecret: String?

    enum CodingKeys: String, CodingKey {
        case signature = "auth"
        case userData = "channel_data"
        case sharedSecret = "shared_secret"
    }
}
