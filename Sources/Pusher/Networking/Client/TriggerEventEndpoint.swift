import APIota
import Foundation

/// Triggers an event on one or more channels.
struct TriggerEventEndpoint: APIotaCodableEndpoint {

    typealias SuccessResponse = ChannelSummaryListAPIResponse
    typealias ErrorResponse = Data
    typealias Body = Event

    let encoder: JSONEncoder = JSONEncoder()

    var headers: HTTPHeaders? {

        var headers = APIClient.defaultHeaders
        headers.replaceOrAdd(header: .contentType, value: HTTPMediaType.json.toString())

        return headers
    }

    let httpBody: Event?

    let httpMethod: HTTPMethod = .POST

    var path: String {

        return "/apps/\(options.appId)/events"
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
}
