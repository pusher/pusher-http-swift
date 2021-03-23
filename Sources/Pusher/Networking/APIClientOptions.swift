import Foundation

/// A collection of configuration options for a Pusher Channels HTTP API client.
public struct APIClientOptions {

    let appId: Int

    let key: String

    let secret: String

    let useTLS: Bool

    let host: String

    let cluster: String

    let port: Int

    let scheme: String

    let httpProxy: String

    let encryptionMasterKeyBase64: String
}
