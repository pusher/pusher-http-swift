import Foundation

/// Provides functionality for generating authentication signatures for private or presence channel subscriptions.
///
/// The generated authentication signature (and other information depending on the channel configuration)
/// are returned in an authentication token object.
struct AuthTokenService {

    /// Generate an authentication token.
    /// - Parameters:
    ///   - channel: The `Channel` for which to generate the authentication token.
    ///   - socketId: The socket identifier `String` for the connected user.
    ///   - userData: User data containing information to share about a connected user.
    ///               (This must be set when generating an authentication token for a presence channel).
    ///   - options: Configuration options used to managing the connection.
    /// - Throws: A `PusherError` if generating the authentication token fails for some reason.
    /// - Returns: An `AuthToken`, which can be encoded onto a `URLRequest`.
    static func authToken(for channel: Channel,
                          socketId: String,
                          userData: PresenceUserAuthData?,
                          using options: PusherClientOptions) throws -> AuthToken {

        guard channel.type != .public else {
            let reason = """
            Auth token generation failed with error: \
            Authenticating public channel subscriptions is not required.
            """
            throw PusherError.invalidConfiguration(reason: reason)
        }

        if channel.type == .presence {
            guard userData != nil else {
                let reason = """
                Auth token generation failed with error: \
                Authenticating presence channel subscriptions requires 'userData'.
                """
                throw PusherError.invalidConfiguration(reason: reason)
            }
        }

        var stringToSign = "\(socketId):\(channel.internalName)"
        var userDataString: String?
        if userData != nil {
            userDataString = try JSONEncoder().encode(userData).toString()
            stringToSign += ":\(userDataString!)"
        }

        let signature = Crypto.sha256HMAC(for: stringToSign.toData(),
                                          using: options.secret.toData())
        let authSignature = "\(options.key):\(signature.hexEncodedString())"

        var sharedSecret: String?
        if channel.type == .encrypted {
            let stringToDigest = "\(channel.internalName)\(options.encryptionMasterKeyBase64)"
            sharedSecret = Crypto.sha256Digest(data: stringToDigest.toData()).base64EncodedString()
        }

        return AuthToken(signature: authSignature,
                         userData: userDataString,
                         sharedSecret: sharedSecret)
    }
}
