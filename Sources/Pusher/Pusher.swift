import APIota

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
                         callback: @escaping (Result<[ChannelSummary], Error>) -> Void) {

        apiClient.sendRequest(for: GetChannelsEndpoint(channelFilter: filter,
                                                       channelAttributes: attributes,
                                                       options: options)) { result in

            // Map the API response to `[ChannelSummary]` when running the callback
            callback(result.map { $0.summaries })
        }
    }

    public func channelInfo(for channel: Channel,
                            attributes: ChannelAttributes,
                            callback: @escaping (Result<ChannelInfo, Error>) -> Void) {

        apiClient.sendRequest(for: GetChannelEndpoint(channel: channel,
                                                      channelAttributes: attributes,
                                                      options: options),
                              callback: callback)
    }

    public func users(for channel: Channel,
                      callback: @escaping (Result<[User], Error>) -> Void) {

        apiClient.sendRequest(for: GetUsersEndpoint(channel: channel,
                                                    options: options)) { result in

            // Map the API response to `[User]` when running the callback
            callback(result.map { $0.users })
        }
    }

    public func trigger(event: Event,
                        callback: @escaping (Result<[ChannelSummary]?, Error>) -> Void) {

        apiClient.sendRequest(for: TriggerEventEndpoint(httpBody: event,
                                                        options: options),
                              callback: callback)
    }

    public func trigger(events: [BatchEvent],
                        callback: @escaping (Result<[ChannelInfo]?, Error>) -> Void) {

        apiClient.sendRequest(for: TriggerBatchEventsEndpoint(httpBody: events,
                                                              options: options),
                              callback: callback)
    }
}
