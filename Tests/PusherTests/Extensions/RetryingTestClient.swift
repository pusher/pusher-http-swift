import Foundation
@testable import Pusher

/// A test-only wrapper around `Pusher` that transparently retries, with exponential
/// backoff, any request that fails with a transient, transport-level connection error
/// rather than a genuine application-level error.
///
/// This exists purely to absorb known CI-environment network flakiness when integration
/// tests hit the real Pusher API (see `NSURLErrorDomain` -1005, "The network connection
/// was lost") - it does not touch, wrap, or change any production library code, and a
/// genuine application error (e.g. a validation failure returned by the API) is never
/// retried, only passed straight through.
final class RetryingTestClient {

    private let pusher: Pusher
    private let maxAttempts: Int
    private let baseDelay: TimeInterval

    init(pusher: Pusher, maxAttempts: Int = 3, baseDelay: TimeInterval = 0.5) {
        self.pusher = pusher
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }

    private static let retriableURLErrorCodes: Set<URLError.Code> = [
        .networkConnectionLost,
        .timedOut,
        .cannotConnectToHost,
        .notConnectedToInternet,
        .dnsLookupFailed
    ]

    private func retrying<T>(attempt: Int = 0,
                             request: @escaping (@escaping (Result<T, PusherError>) -> Void) -> Void,
                             callback: @escaping (Result<T, PusherError>) -> Void) {

        request { result in
            if case .failure(let error) = result,
               attempt < self.maxAttempts,
               case .internalError(let underlyingError) = error,
               let urlError = underlyingError as? URLError,
               Self.retriableURLErrorCodes.contains(urlError.code) {

                let delay = self.baseDelay * pow(2.0, Double(attempt))
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    self.retrying(attempt: attempt + 1, request: request, callback: callback)
                }
            } else {
                callback(result)
            }
        }
    }

    // MARK: - Application state queries (retried)

    func channels(withFilter filter: ChannelFilter = .any,
                  attributeOptions: ChannelAttributeFetchOptions = [],
                  callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {
        retrying(request: { completion in
            self.pusher.channels(withFilter: filter, attributeOptions: attributeOptions, callback: completion)
        }, callback: callback)
    }

    func channelInfo(for channel: Channel,
                     attributeOptions: ChannelAttributeFetchOptions = [],
                     callback: @escaping (Result<ChannelInfo, PusherError>) -> Void) {
        retrying(request: { completion in
            self.pusher.channelInfo(for: channel, attributeOptions: attributeOptions, callback: completion)
        }, callback: callback)
    }

    func users(for channel: Channel,
               callback: @escaping (Result<[User], PusherError>) -> Void) {
        retrying(request: { completion in
            self.pusher.users(for: channel, callback: completion)
        }, callback: callback)
    }

    // MARK: - Triggering events (retried)

    func trigger(event: Event,
                 callback: @escaping (Result<[ChannelSummary], PusherError>) -> Void) {
        retrying(request: { completion in
            self.pusher.trigger(event: event, callback: completion)
        }, callback: callback)
    }

    func trigger(events: [Event],
                 callback: @escaping (Result<[ChannelInfo], PusherError>) -> Void) {
        retrying(request: { completion in
            self.pusher.trigger(events: events, callback: completion)
        }, callback: callback)
    }

    // MARK: - Pure local operations (passed straight through, no network call to retry)

    func authenticate(channel: Channel,
                      socketId: String,
                      userData: PresenceUserData? = nil,
                      callback: @escaping (Result<AuthenticationToken, PusherError>) -> Void) {
        pusher.authenticate(channel: channel, socketId: socketId, userData: userData, callback: callback)
    }

    func verifyWebhook(request: URLRequest,
                       callback: @escaping (Result<Webhook, PusherError>) -> Void) {
        pusher.verifyWebhook(request: request, callback: callback)
    }
}
