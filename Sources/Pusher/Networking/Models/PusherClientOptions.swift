import Foundation

/// A collection of configuration options for a Pusher Channels HTTP API client.
public struct PusherClientOptions {

    /// The application identifier (as specified in the Channels developer dashboard).
    public let appId: Int

    /// The application key (as specified in the Channels developer dashboard).
    public let key: String

    /// The application secret (as specified in the Channels developer dashboard).
    public let secret: String

    /// The master key used for server-side encryption operations.
    ///
    /// The master key is never shared with Pusher and should be kept secret.
    /// It should be a Base-64 encoded `String` of 32 bytes of random data.
    /// An example command for generating such a key is: `"openssl rand -base64 32"`.
    public let encryptionMasterKey: String

    /// The Pusher cluster that hosts the Channels application
    /// (as specified in the Channels developer dashboard).
    ///
    /// This will be `nil` if a custom `host` is provided.
    public let cluster: String?

    /// The host of the Channels application.
    public let host: String

    /// A HTTP proxy to use when routing traffic to a custom `host`.
    ///
    /// The default value is `nil`.
    public let httpProxy: String?

    /// The port to use when routing traffic to the `host`.
    public let port: Int

    /// The scheme to use when routing traffic to the `host`.
    public let scheme: String

    /// Whether or not Transport Layer Security is used when
    /// sending and receiving traffic to and from the `host`.
    ///
    /// The default value is `true`.
    public let useTLS: Bool

    // MARK: - Lifecycle

    /// Creates a `PusherClientOptions` instance using the default set of configuration options
    /// provided by the Pusher Channels developer dashboard.
    /// - Parameters:
    ///   - appId: The application identifier (as specified in the Channels developer dashboard).
    ///   - key: The application key (as specified in the Channels developer dashboard).
    ///   - secret: The application secret (as specified in the Channels developer dashboard).
    ///   - encryptionMasterKey: The master key used for server-side encryption operations.
    ///                          (Refer to the property itself for information on its expected format).
    ///   - cluster: The Pusher cluster that hosts the Channels application
    ///              (as specified in the Channels developer dashboard).
    ///   - useTLS: Whether or not Transport Layer Security is used when
    ///             sending and receiving traffic to and from the `host`.
    ///             The default value is `true`.
    /// - Throws: A `PusherError` if the configuration options are invalid for some reason.
    public init(appId: Int,
                key: String,
                secret: String,
                encryptionMasterKey: String,
                cluster: String,
                useTLS: Bool = true) throws {
        try self.init(appId: appId,
                      key: key,
                      secret: secret,
                      encryptionMasterKey: encryptionMasterKey,
                      cluster: cluster,
                      host: nil,
                      useTLS: useTLS)
    }

    /// Creates a `PusherClientOptions` instance from a collection of configuration options.
    /// - Parameters:
    ///   - appId: The application identifier (as specified in the Channels developer dashboard).
    ///   - key: The application key (as specified in the Channels developer dashboard).
    ///   - secret: The application secret (as specified in the Channels developer dashboard).
    ///   - encryptionMasterKey: The master key used for server-side encryption operations.
    ///   - cluster: The Pusher cluster that hosts the Channels application
    ///              (as specified in the Channels developer dashboard).
    ///   - host: A custom host for a Channels application (e.g. `"myhost.com"`).
    ///   - httpProxy: A HTTP proxy to use when routing traffic to a custom `host`.
    ///   - port: A port to use when routing traffic to a custom `host`.
    ///   - scheme: A scheme to use when routing traffic to a custom `host`.
    ///   - useTLS: Whether or not Transport Layer Security is used when
    ///             sending and receiving traffic to and from the `host`.
    /// - Throws: A `PusherError` if the configuration options are invalid for some reason.
    public init(appId: Int,
                key: String,
                secret: String,
                encryptionMasterKey: String,
                cluster: String? = nil,
                host: String? = nil,
                httpProxy: String? = nil,
                port: Int? = nil,
                scheme: String? = nil,
                useTLS: Bool = true) throws {

        guard Data(base64Encoded: encryptionMasterKey) != nil else {
            let reason = "The provided 'encryptionMasterKey' value is not a valid Base-64 string."
            throw PusherError.invalidConfiguration(reason: reason)
        }

        if let host = host {
            guard !host.hasPrefix("http://") && !host.hasPrefix("https://") else {
                let reason = "The provided 'host' value should not have a 'https://' or 'http://' prefix."
                throw PusherError.invalidConfiguration(reason: reason)
            }

            guard !host.hasSuffix("/") else {
                let reason = "The provided 'host' value should not have a '/' suffix."
                throw PusherError.invalidConfiguration(reason: reason)
            }
        }

        self.appId = appId
        self.key = key
        self.secret = secret
        self.encryptionMasterKey = encryptionMasterKey
        self.httpProxy = httpProxy
        self.useTLS = useTLS

        // Set `host` directly to a provided value, or base it on a provided `cluster`
        // Otherwise if neither are provided, set a default value based on the 'mt1' cluster
        if let host = host {
            self.host = host
            self.cluster = nil
        } else if let cluster = cluster {
            self.cluster = cluster
            self.host = "api-\(self.cluster!).pusher.com"
        } else {
            guard port != nil, scheme != nil else {
                let reason = "A 'host' should be provided if a custom 'port' or 'scheme' is set."
                throw PusherError.invalidConfiguration(reason: reason)
            }

            self.cluster = "mt1"
            self.host = "api-\(self.cluster!).pusher.com"
        }

        // Set `port` and `scheme` to TLS defaults if `useTLS` == true
        // Otherwise set to provided values, or use 80 / "http" as a fallback if value(s) not provided
        if self.useTLS {
            self.port = 443
            self.scheme = "https"
        } else {
            self.port = port != nil ? port! : 80
            self.scheme = scheme != nil ? scheme! : "http"
        }
    }
}
