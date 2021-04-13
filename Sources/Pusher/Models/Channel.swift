import Foundation

public struct Channel: ChannelDescription {

    public let name: String

    var internalName: String {
        switch type {
        case .encrypted, .presence, .private:
            return "\(type.rawValue)-\(name)"
        case .public:
            return name
        }
    }

    public let type: ChannelType
}
