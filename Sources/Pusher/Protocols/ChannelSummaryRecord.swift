import Foundation

/// A summarised information record for a specific channel.
protocol ChannelSummaryRecord {

    /// The channel name.
    var name: String { get }

    var attributes: ChannelAttributes { get }

    /// The channel type.
    var type: ChannelType { get }
}
