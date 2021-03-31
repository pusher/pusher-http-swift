import APIota
@testable import Pusher
import XCTest

final class PusherTests: XCTestCase {

    private static let pusher = Pusher(options: APIClientOptions(appId: 1070530,
                                                         key: "b5390e69136683c40d2d",
                                                         secret: "24aaea961cfe1335f796",
                                                         useTLS: true,
                                                         host: "api-eu.pusher.com",
                                                         cluster: "eu",
                                                         port: 443,
                                                         scheme: "https",
                                                         httpProxy: "",
                                                         encryptionMasterKeyBase64: "a7QyXV8eYrtJBehbuix68XCPO6+LrpnNNReWOkaXW7A="))

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
        Self.pusher.channels(withFilter: .private,
                             attributes: .userCount) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                let apiError = error as? APIotaClientError
                XCTAssertNotNil(apiError)
                XCTAssertEqual(apiError, .failedResponse(statusCode: .badRequest))
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
        Self.pusher.channelInfo(for: Channel(name: "my-channel",
                                             type: .public),
                                attributes: .userCount) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                let apiError = error as? APIotaClientError
                XCTAssertNotNil(apiError)
                XCTAssertEqual(apiError, .failedResponse(statusCode: .badRequest))
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
        Self.pusher.users(for: Channel(name: "my-channel",
                                       type: .public)) { result in
            switch result {
            case .success:
                XCTFail("This test should not succeed.")

            case .failure(let error):
                let apiError = error as? APIotaClientError
                XCTAssertNotNil(apiError)
                XCTAssertEqual(apiError, .failedResponse(statusCode: .badRequest))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
