import APIota
@testable import Pusher
import XCTest

final class PusherTests: XCTestCase {

    private static let pusher = TestObjects.pusher

    // MARK: - GET channels tests

    func testGetChannelsSucceeds() {
        let expectation = XCTestExpectation(function: #function)
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
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        user_count may only be requested for presence channels - \
        please supply filter_by_prefix begining with presence-\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        Self.pusher.channels(withFilter: .private,
                             attributes: .userCount) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - GET channel info tests

    func testGetChannelInfoSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.channelInfo(for: TestObjects.publicChannel,
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
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        Cannot retrieve the user count unless the channel is a presence channel\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        Self.pusher.channelInfo(for: TestObjects.publicChannel,
                                attributes: .userCount) { result in
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
