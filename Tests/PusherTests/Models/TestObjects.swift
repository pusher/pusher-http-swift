import Foundation
@testable import Pusher

struct TestObjects {

    // MARK: - SDK client

    private static let testKey = "b5390e69136683c40d2d"
    private static let testSecret = "24aaea961cfe1335f796"
    private static let testCluster = "eu"
    private static let testMasterKey = "a7QyXV8eYrtJBehbuix68XCPO6+LrpnNNReWOkaXW7A="
    static let pusher = Pusher(options: APIClientOptions(appId: 1070530,
                                                         key: testKey,
                                                         secret: testSecret,
                                                         useTLS: true,
                                                         host: "api-eu.pusher.com",
                                                         cluster: testCluster,
                                                         port: 443,
                                                         scheme: "https",
                                                         httpProxy: "",
                                                         encryptionMasterKeyBase64: testMasterKey))

    // MARK: - Channels

    static let presenceChannel = Channel(name: "my-channel", type: .presence)
    static let publicChannel = Channel(name: "my-channel", type: .public)
}
