import Foundation

/// An information record for an event on a received Webhook.
protocol WebhookEventRecord: Codable {

    /// The event type.
    var eventType: WebhookEventType { get }

    /// The channel name relating to the Webhook event.
    var channelName: String { get }

    /// The event name (only set if `eventType` is `.clientEvent`).
    var eventName: String? { get }

    /// The event data (only set if `eventType` is `.clientEvent`).
    var eventData: Data? { get }

    /// The identifier of the socket that sent the event (only set if `eventType` is `.clientEvent`).
    var socketId: String? { get }

    /// The user identifier associated with the socket that sent the event (only set for presence channels).
    var userId: String? { get }
}
