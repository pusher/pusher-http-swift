import APIota
import Foundation

/// Triggers multiple events on one or more channels in a single request.
struct TriggerBatchEventsEndpoint: APIotaCodableEndpoint {

    typealias SuccessResponse = ChannelAttributesListAPIResponse
    typealias ErrorResponse = Data
    typealias Body = EventBatch

    /// Represents a batch of events to be triggered in a single API request.
    struct EventBatch: Encodable {
        /// The array of events to trigger.
        let batch: [Event]
    }

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

        // Add array of `URLQueryItem` for authenticating the `URLRequest`
        let authInfo = AuthInfo(httpBody: httpBody,
                                httpMethod: httpMethod.rawValue,
                                path: path,
                                key: options.key,
                                secret: options.secret)

        return authInfo.queryItems
    }

    /// Configuration options which are used when initializing the `URLRequest`.
    let options: APIClientOptions

    // MARK: - Lifecycle

    init(events: [Event], options: APIClientOptions) {
        self.httpBody = EventBatch(batch: events)
        self.options = options
    }
}
