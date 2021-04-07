import APIota
import Foundation

/// Manages operations when interacting with the Pusher Channels HTTP API.
public class Pusher {

    // MARK: - Properties

    private let apiClient: APIotaClient

    private let options: APIClientOptions

    // MARK: - Lifecycle

    /// Creates a Pusher Channels HTTP API client from a set of options.
    /// - Parameter options: Configuration options used to managing the connection.
    init(options: APIClientOptions) {
        self.apiClient = APIClient(options: options)
        self.options = options
    }

    /// Creates a Pusher Channels HTTP API client from a type conforming to `APIotaClient`.
    /// - Parameter apiClient: The API client used to manage the connection.
    /// - Parameter options: Configuration options used to managing the connection.
    init(apiClient: APIotaClient, options: APIClientOptions) {
        self.apiClient = apiClient
        self.options = options
    }

    // MARK: - Public methods

    public func channels(withFilter filter: ChannelFilter,
                         attributes: ChannelAttributes,
                         callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {

        apiClient.sendRequest(for: GetChannelsEndpoint(channelFilter: filter,
                                                       channelAttributes: attributes,
                                                       options: options)) { result in

            // Map the API response to `[ChannelSummary]` when running the callback
            // and map the API client error to an equivalent `PusherError`
            callback(result
                        .map { $0.summaries }
                        .mapError({ PusherError(error: $0) }))
        }
    }

    public func channelInfo(for channel: Channel,
                            attributes: ChannelAttributes,
                            callback: @escaping (Result<ChannelInfo, PusherError>) -> Void) {

        apiClient.sendRequest(for: GetChannelEndpoint(channel: channel,
                                                      channelAttributes: attributes,
                                                      options: options)) { result in

            // Map the API client error to an equivalent `PusherError`
            callback(result.mapError({ PusherError(error: $0) }))
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
                        .mapError({ PusherError(error: $0) }))
        }
    }

    public func trigger(event: Event,
                        callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {

        apiClient.sendRequest(for: TriggerEventEndpoint(httpBody: event,
                                                        options: options)) { result in

            // Map the API client error to an equivalent `PusherError`
            callback(result
                        .map { $0.summaries }
                        .mapError({ PusherError(error: $0) }))
        }
    }

    public func trigger(events: [BatchEvent],
                        callback: @escaping (Result<[ChannelInfo]?, PusherError>) -> Void) {

        apiClient.sendRequest(for: TriggerBatchEventsEndpoint(httpBody: events,
                                                              options: options)) { result in

            // Map the API client error to an equivalent `PusherError`
            callback(result.mapError({ PusherError(error: $0) }))
        }
    }
}
