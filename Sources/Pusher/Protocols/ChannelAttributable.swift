import Foundation

protocol ChannelAttributable {

    /// The attributes of the channel that can be fetched depending on the `ChannelAttributeFetchOptions`
    /// provided to a top-level API method (see `Pusher.swift`).
    var attributes: ChannelAttributes { get }
}
