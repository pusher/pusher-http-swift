import APIota
@testable import Pusher
import XCTest

final class AppStateQueryTests: XCTestCase {

    private static let pusher = TestObjects.Client.shared

    // MARK: - GET channels tests

    func testGetChannelsSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.channels { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetChannelsFailsForInvalidAttributes() {
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        user_count may only be requested for presence channels - \
        please supply filter_by_prefix begining with presence-\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        Self.pusher.channels(withFilter: .private,
                             attributeOptions: .userCount) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET channel info tests

    func testGetChannelInfoSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.channelInfo(for: TestObjects.publicChannel) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelInfo in
                XCTAssertNotNil(channelInfo)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetChannelInfoFailsForInvalidAttributes() {
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        Cannot retrieve the user count unless the channel is a presence channel\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        Self.pusher.channelInfo(for: TestObjects.publicChannel,
                                attributeOptions: .userCount) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET users tests

    func testGetUsersForChannelSucceedsForPresenceChannel() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.users(for: TestObjects.presenceChannel) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { users in
                XCTAssertEqual(users.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testGetUsersForChannelFailsForPublicChannel() {
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        Users can only be retrieved for presence channels\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        Self.pusher.users(for: TestObjects.publicChannel) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
