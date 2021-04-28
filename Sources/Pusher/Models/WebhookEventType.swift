import Foundation

/// The available Webhook event types.
public enum WebhookEventType: String, Codable {

    /// A channel has become occupied. (i.e. there is at least one subscriber).
    case channelOccupied = "channel_occupied"

    /// A channel has become vacated. (i.e. there are no subscribers).
    case channelVacated = "channel_vacated"

    /// A user has subscribed to a presence channel.
    case memberAdded = "member_added"

    /// A user has unsubscribed from a presence channel.
    case memberRemoved = "member_removed"

    /// A client event has been triggered on a private or presence channel.
    case clientEvent = "client_event"
}
