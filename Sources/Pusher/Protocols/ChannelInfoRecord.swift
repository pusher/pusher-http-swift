import Foundation

/// An information record for a specific channel.
protocol ChannelInfoRecord {

    /// If there is at least one user subscribed to the channel, it is classed as occupied.
    var isOccupied: Bool { get }

    var attributes: ChannelAttributes { get }
}
