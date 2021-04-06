import APIota
@testable import Pusher
import XCTest

final class PusherTests: XCTestCase {

    private static let testKey = "b5390e69136683c40d2d"
    private static let testSecret = "24aaea961cfe1335f796"
    private static let testCluster = "eu"
    private static let testMasterKey = "a7QyXV8eYrtJBehbuix68XCPO6+LrpnNNReWOkaXW7A="
    private static let pusher = Pusher(options: APIClientOptions(appId: 1070530,
                                                                 key: testKey,
                                                                 secret: testSecret,
                                                                 useTLS: true,
                                                                 host: "api-eu.pusher.com",
                                                                 cluster: testCluster,
                                                                 port: 443,
                                                                 scheme: "https",
                                                                 httpProxy: "",
                                                                 encryptionMasterKeyBase64: testMasterKey))

    // MARK: - GET channels tests

    func testGetChannelsSucceeds() {
        let expectation = XCTestExpectation(description: "testGetChannelsSucceedsExpectation")
        Self.pusher.channels(withFilter: .any,
                             attributes: []) { result in
            switch result {
            case .success(let channelSummaries):
                XCTAssertEqual(channelSummaries.count, 0)

            case .failure(let error):
                XCTFail("This test should not fail. Failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetChannelsFailsForInvalidAttributes() {
        let expectation = XCTestExpectation(description: "testGetChannelsSucceedsExpectation")
        let expectedErrorMessage = """
        user_count may only be requested for presence channels - \
        please supply filter_by_prefix begining with presence-\n
        """
        Self.pusher.channels(withFilter: .private,
                             attributes: .userCount) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                XCTAssertEqual(error, .failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                      errorResponse: expectedErrorMessage))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET channel info tests

    func testGetChannelInfoSucceeds() {
        let expectation = XCTestExpectation(description: "testGetChannelInfoSucceedsExpectation")
        Self.pusher.channelInfo(for: Channel(name: "my-channel",
                                             type: .public),
                                attributes: []) { result in
            switch result {
            case .success(let channelInfo):
                XCTAssertNotNil(channelInfo)

            case .failure(let error):
                XCTFail("This test should not fail. Failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetChannelInfoFailsForInvalidAttributes() {
        let expectation = XCTestExpectation(description: "testGetChannelInfoSucceedsExpectation")
        let expectedErrorMessage = """
        Cannot retrieve the user count unless the channel is a presence channel\n
        """
        Self.pusher.channelInfo(for: Channel(name: "my-channel",
                                             type: .public),
                                attributes: .userCount) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                XCTAssertEqual(error, .failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                      errorResponse: expectedErrorMessage))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET users tests

    func testGetUsersForChannelSucceedsForPresenceChannel() {
        let expectation = XCTestExpectation(description: "testGetUsersForChannelSucceedsForPresenceChannelExpectation")
        Self.pusher.users(for: Channel(name: "my-channel",
                                       type: .presence)) { result in
            switch result {
            case .success(let users):
                XCTAssertEqual(users.count, 0)

            case .failure(let error):
                XCTFail("This test should not fail. Failed with error: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetUsersForChannelFailsForPublicChannel() {
        let expectation = XCTestExpectation(description: "testGetUsersForChannelFailsForNonPresenceChannelExpectation")
        let expectedErrorMessage = """
        Users can only be retrieved for presence channels\n
        """
        Self.pusher.users(for: Channel(name: "my-channel",
                                       type: .public)) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                XCTAssertEqual(error, .failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                      errorResponse: expectedErrorMessage))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
