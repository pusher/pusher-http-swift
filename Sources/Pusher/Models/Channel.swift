import Foundation

/// A channel that can be queried for information, or be published to using an `Event`.
public struct Channel: ChannelDescription {

    /// The channel name.
    ///
    /// This is the channel name without the type identifier prefix, e.g. `"my-channel"`.
    /// It therefore does not expose channel type information, which can be inspected using `type`.
    public let name: String

    /// The full channel name.
    ///
    /// This is the channel name including the type identifier prefix, e.g. `"private-my-channel"`.
    /// It is inferred from the `name` and the `type`.
    var internalName: String {
        switch type {
        case .encrypted, .presence, .private:
            return "\(type.rawValue)-\(name)"
        case .public:
            return name
        }
    }

    /// The channel type.
    public let type: ChannelType
}
