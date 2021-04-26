#if !canImport(ObjectiveC)
import XCTest

extension PusherTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PusherTests = [
        ("testGetChannelInfoFailsForInvalidAttributes", testGetChannelInfoFailsForInvalidAttributes),
        ("testGetChannelInfoSucceeds", testGetChannelInfoSucceeds),
        ("testGetChannelsFailsForInvalidAttributes", testGetChannelsFailsForInvalidAttributes),
        ("testGetChannelsSucceeds", testGetChannelsSucceeds),
        ("testGetUsersForChannelFailsForPublicChannel", testGetUsersForChannelFailsForPublicChannel),
        ("testGetUsersForChannelSucceedsForPresenceChannel", testGetUsersForChannelSucceedsForPresenceChannel),
        ("testPostBatchEventsToChannelFailsForMultichannelEvents", testPostBatchEventsToChannelFailsForMultichannelEvents),
        ("testPostBatchEventsToChannelFailsForTooLargeBatch", testPostBatchEventsToChannelFailsForTooLargeBatch),
        ("testPostBatchEventsToChannelSucceedsForSingleChannelEvents", testPostBatchEventsToChannelSucceedsForSingleChannelEvents),
        ("testPostEventToChannelFailsForInvalidMultichannelEvent", testPostEventToChannelFailsForInvalidMultichannelEvent),
        ("testPostEventToChannelSucceedsForEncryptedChannel", testPostEventToChannelSucceedsForEncryptedChannel),
        ("testPostEventToChannelSucceedsForPrivateChannel", testPostEventToChannelSucceedsForPrivateChannel),
        ("testPostEventToChannelSucceedsForPublicChannel", testPostEventToChannelSucceedsForPublicChannel),
        ("testPostEventToChannelSucceedsForValidMultichannelEvent", testPostEventToChannelSucceedsForValidMultichannelEvent),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PusherTests.__allTests__PusherTests),
    ]
}
#endif
