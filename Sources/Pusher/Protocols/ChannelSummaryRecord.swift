import Foundation

/// A summarised information record for a specific channel.
protocol ChannelSummaryRecord: ChannelAttributable {

    /// The channel name.
    var name: String { get }

    /// The channel type.
    var type: ChannelType { get }
}
