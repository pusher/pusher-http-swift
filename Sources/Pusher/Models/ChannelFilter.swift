import Foundation

/// A filter that may be applied when fetching information on occupied channels from the HTTP API.
public enum ChannelFilter {

    /// A filter encapsulating any channel that can be subscribed to.
    ///
    /// Channels returned could be any of the following types: `encrypted`, `private`, `presence` or `public`.
    case any

    /// A custom filter, based on a provided channel name prefix `String`.
    ///
    /// This can be used as a filter for a particular group of channels, defined by a common naming prefix scheme.
    case custom(prefix: String)

    /// A filter encapsulating end-to-end encrypted channels.
    case encrypted

    /// A filter encapsulating private channels.
    case `private`

    /// A filter encapsulating presence channels.
    case presence
}

extension ChannelFilter {

    /// A channel name prefix `String`, depending on the `ChannelFilter` value.
    private var channelPrefix: String {
        switch self {
        case .any:
            return ""
        case .custom(prefix: let customPrefix):
            return customPrefix

        case .encrypted:
            return "private-encrypted-"
        case .private:
            return "private-"
        case .presence:
            return "presence-"
        }
    }

    /// A `URLQueryItem` that can be used as a filter when requesting info on occupied channels.
    var queryItem: URLQueryItem? {
        switch self {
        case .any:
            return nil

        case .custom(prefix: _), .encrypted, .private, .presence:
            return URLQueryItem(name: "filter_by_prefix", value: channelPrefix)
        }
    }
}
