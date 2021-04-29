import APIota
import Foundation

/// Manages operations when interacting with the Pusher Channels HTTP API.
public class Pusher {

    // MARK: - Properties

    private let apiClient: APIotaClient

    private let options: PusherClientOptions

    // MARK: - Lifecycle

    /// Creates a Pusher Channels HTTP API client from a set of options.
    /// - Parameter options: Configuration options used to managing the connection.
    public init(options: PusherClientOptions) {
        self.apiClient = APIClient(options: options)
        self.options = options
    }

    /// Creates a Pusher Channels HTTP API client from a type conforming to `APIotaClient`.
    /// - Parameter apiClient: The API client used to manage the connection.
    /// - Parameter options: Configuration options used to managing the connection.
    public init(apiClient: APIotaClient, options: PusherClientOptions) {
        self.apiClient = apiClient
        self.options = options
    }

    // MARK: - Application state queries

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
