import APIota
import Foundation

/// Triggers multiple events on one or more channels in a single request.
struct TriggerBatchEventsEndpoint: APIotaCodableEndpoint {

    typealias SuccessResponse = ChannelAttributesListAPIResponse
    typealias ErrorResponse = Data
    typealias Body = EventBatch

    let encoder: JSONEncoder = JSONEncoder()

    var headers: HTTPHeaders? {

        var headers = APIClient.defaultHeaders
        headers.replaceOrAdd(header: .contentType, value: HTTPMediaType.json.toString())

        return headers
    }

    let httpBody: EventBatch?

    let httpMethod: HTTPMethod = .POST

    var path: String {

        return "/apps/\(options.appId)/batch_events"
    }

    var queryItems: [URLQueryItem]? {

        // Initialize 'additional' query items (i.e. for requested channel attributes)
        let attributesQueryItems = attributeOptions.queryItems

        // Add array of `URLQueryItem` for authenticating the `URLRequest`
        let authInfo = AuthInfo(httpBody: httpBody,
                                httpMethod: httpMethod.rawValue,
                                path: path,
                                key: options.key,
                                secret: options.secret,
                                additionalQueryItems: attributesQueryItems)

        return authInfo.queryItems
    }

    /// The channel attributes to fetch that will be present in the API response.
    let attributeOptions: ChannelAttributeFetchOptions

    /// Configuration options which are used when initializing the `URLRequest`.
    let options: PusherClientOptions

    // MARK: - Lifecycle

    init(events: [Event], attributeOptions: ChannelAttributeFetchOptions, options: PusherClientOptions) {
        self.httpBody = EventBatch(batch: events)
        self.attributeOptions = attributeOptions
        self.options = options
    }
}
