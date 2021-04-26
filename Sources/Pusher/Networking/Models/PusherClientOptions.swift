import Foundation

/// A collection of configuration options for a Pusher Channels HTTP API client.
public struct PusherClientOptions {

    public let appId: Int

    public let key: String

    public let secret: String

    public let useTLS: Bool

    public let host: String

    public let cluster: String

    public let port: Int

    public let scheme: String

    public let httpProxy: String

    public let encryptionMasterKeyBase64: String
}
