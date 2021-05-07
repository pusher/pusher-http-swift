import APIota
import Foundation

/// Manages operations when interacting with the Pusher Channels HTTP API.
public class Pusher {

    // MARK: - Properties

    /// The API client used for querying app state via the Channels HTTP API.
    private let apiClient: APIotaClient

    /// Configuration options used to managing the connection.
    private let options: PusherClientOptions

    // MARK: - Lifecycle

    /// Creates a Pusher Channels HTTP API client configured using some `options`.
    /// - Parameter options: Configuration options used to managing the connection.
    public init(options: PusherClientOptions) {
        self.apiClient = APIClient(options: options)
        self.options = options
    }

    /// Creates a Pusher Channels HTTP API client from a type conforming to `APIotaClient`.
    /// - Parameter apiClient: The API client used to manage the connection.
    /// - Parameter options: Configuration options used to managing the connection.
    init(apiClient: APIotaClient, options: PusherClientOptions) {
        self.apiClient = apiClient
        self.options = options
    }

    // MARK: - Application state queries

    /// Fetch a list of any occupied channels.
    ///
    /// The results can be filtered by channel type, or a user-specified prefix
    /// that allows filtering based on custom naming schemes.
    /// - Parameters:
    ///   - filter: A filter to apply to the returned results.
    ///   - attributeOptions: A set of attributes that should be returned for each result.
    ///   - callback: A closure that returns a `Result` containing a list of occupied
    ///               channels (and their requested attributes), or a `PusherError`
    ///               if the operation fails for some reason.
    public func channels(withFilter filter: ChannelFilter = .any,
                         attributeOptions: ChannelAttributeFetchOptions = [],
                         callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {

        apiClient.sendRequest(for: GetChannelsEndpoint(channelFilter: filter,
                                                       attributeOptions: attributeOptions,
                                                       options: options)) { result in

            // Map the API response to `[ChannelSummary]` when running the callback
            // and map the API client error to an equivalent `PusherError`
            callback(result
                        .map { $0.channelSummaryList }
                        .mapError({ PusherError(from: $0) }))
        }
    }

    /// Fetch attributes of a given occupied channel.
    /// - Parameters:
    ///   - channel: The channel to inspect.
    ///   - attributeOptions: A set of attributes that should be returned for the `channel`.
    ///   - callback: A closure that returns a `Result` containing the requested information
    ///               for the `channel`, or a `PusherError` if the operation fails for some reason.
    public func channelInfo(for channel: Channel,
                            attributeOptions: ChannelAttributeFetchOptions = [],
                            callback: @escaping (Result<ChannelInfo, PusherError>) -> Void) {

        apiClient.sendRequest(for: GetChannelEndpoint(channel: channel,
                                                      attributeOptions: attributeOptions,
                                                      options: options)) { result in

            // Map the API client error to an equivalent `PusherError`
            callback(result.mapError({ PusherError(from: $0) }))
        }
    }

    /// Fetch a list of users currently subscribed to a given occupied presence channel.
    ///
    /// Attempting to fetch a list of users for non-presence channels is invalid and
    /// will result in an error.
    /// - Parameters:
    ///   - channel: The presence channel to inspect.
    ///   - callback: A closure that returns a `Result` containing the subscribed users
    ///               for the `channel`, or a `PusherError` if the operation fails for some reason.
    public func users(for channel: Channel,
                      callback: @escaping (Result<[User], PusherError>) -> Void) {

        apiClient.sendRequest(for: GetUsersEndpoint(channel: channel,
                                                    options: options)) { result in

            // Map the API response to `[User]` when running the callback
            // and map the API client error to an equivalent `PusherError`
            callback(result
                        .map { $0.users }
                        .mapError({ PusherError(from: $0) }))
        }
    }

    // MARK: - Triggering events

    /// Trigger an event on one or more channels.
    ///
    /// The channel (or channels) that the event should be triggered on, (as well as the
    /// attributes to fetch for the each channel) are specified when initializing an instance
    /// of `Event` to pass to this method.
    /// - Parameters:
    ///   - event: The event to trigger.
    ///   - callback: A closure that returns a `Result` containing a list of channels that
    ///               were triggered to (and their requested attributes), or a `PusherError`
    ///               if the operation fails for some reason. If the `attributeOptions` on
    ///               the `event` are not set, an empty channel list will be returned.
    public func trigger(event: Event,
                        callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {

        do {
            // Encrypt the `eventData` (if necessary) before triggering the event
            let eventToTrigger = try event.encrypted(using: options)
            apiClient.sendRequest(for: TriggerEventEndpoint(httpBody: eventToTrigger,
                                                            options: options)) { result in

                // Map the API client error to an equivalent `PusherError`
                callback(result
                            .map { $0.channelSummaryList }
                            .mapError({ PusherError(from: $0) }))
            }
        } catch {
            callback(.failure(PusherError(from: error)))
        }
    }

    /// Trigger multiple events, each on a specific channel.
    ///
    /// The channel that the event should be triggered on, (as well as the
    /// attributes to fetch for the each channel) are specified when initializing instances
    /// of `Event` to pass to this method.
    ///
    /// Specifying more than one channel to trigger the event on (or providing a list of
    /// more than 10 events to trigger) is invalid and will result in an error.
    /// - Parameters:
    ///   - events: A list of events to trigger.
    ///   - callback: A closure that returns a `Result` containing the requested information
    ///               for the channels that were triggered to, or a `PusherError`
    ///               if the operation fails for some reason. If the `attributeOptions` on
    ///               the `event` are not set, an empty information list will be returned.
    public func trigger(events: [Event],
                        callback: @escaping (Result<[ChannelInfo], PusherError>) -> Void) {

        do {
            let eventsToTrigger = try events.map { try $0.encrypted(using: options) }
            apiClient.sendRequest(for: TriggerBatchEventsEndpoint(events: eventsToTrigger,
                                                                  options: options)) { result in

                // Map the API client error to an equivalent `PusherError`
                callback(result
                            .map { $0.channelInfoList }
                            .mapError({ PusherError(from: $0) }))
            }
        } catch {
            callback(.failure(PusherError(from: error)))
        }
    }

    // MARK: - Webhook verification

    /// Verify that a received webhook request is genuine and was received from Pusher.
    ///
    /// Since a webhook endpoint is accessible to the global internet, verifying that webhook request
    /// originated from Pusher is important. Valid webhooks contain special headers which contain a
    /// copy of your application key and a HMAC signature of the webhook payload (i.e. its body).
    /// - Parameters:
    ///   - request: The webhook request.
    ///   - callback: A closure that returns a `Result` containing a verified `Webhook` and the
    ///               events that it contains (which are decrypted if needed), or a `PusherError`
    ///               if the operation fails for some reason.
    public func verifyWebhookRequest(_ request: URLRequest,
                                     callback: @escaping (Result<Webhook, PusherError>) -> Void) {

        // Verify request key and signature and then decode into a `Webhook`
        do {
            try WebhookService.verifySignature(of: request, using: options)
            let webhook = try WebhookService.webhook(from: request, using: options)

            callback(.success(webhook))
        } catch {
            callback(.failure(PusherError(from: error)))
        }
    }

    // MARK: - Private and presence channel subscription authentication

    /// Generate an authentication token that can be returned to a user client that is attempting
    /// to subscribe to a private or presence channel, which requires authentication with the server.
    /// - Parameters:
    ///   - channel: The `Channel` for which to generate the authentication token.
    ///   - socketId: The socket identifier `String` for the connected user.
    ///   - userData: User data required when generating an authentication token for a subscription attempt
    ///               to a presence channel.
    ///               (This must be set when generating an authentication token for a presence channel).
    ///   - callback: A closure that returns a `Result` containing an authentication token
    ///               for subscribing to a private or presence channel, or a `PusherError`
    ///               if the operation fails for some reason.
    public func authenticate(channel: Channel,
                             socketId: String,
                             userData: PresenceUserAuthData? = nil,
                             callback: @escaping (Result<AuthToken, PusherError>) -> Void) {

        do {
            let authToken = try AuthTokenService.authToken(for: channel,
                                                           socketId: socketId,
                                                           userData: userData,
                                                           using: options)
            callback(.success(authToken))
        } catch {
            callback(.failure(PusherError(from: error)))
        }
    }
}
