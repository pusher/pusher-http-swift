import APIota
@testable import Pusher
import XCTest

final class PusherTests: XCTestCase {

    private static let pusher = TestObjects.pusher

    // MARK: - GET channels tests

    func testGetChannelsSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.channels(withFilter: .any,
                             attributeOptions: []) { result in
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
        Self.pusher.channelInfo(for: TestObjects.publicChannel,
                                attributeOptions: []) { result in
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

    // MARK: - POST single event tests

    func testPostEventToChannelSucceedsForEncryptedChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.encryptedEvent) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForPrivateChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.privateEvent) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForPublicChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.publicEvent) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForValidMultichannelEvent() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.multichannelEvent) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelFailsForInvalidMultichannelEvent() throws {
        let expectation = XCTestExpectation(function: #function)
        do {
            _ = try Event(eventName: "my-multichannel-event",
                          eventData: TestObjects.eventData,
                          channels: [TestObjects.encryptedChannel,
                                     TestObjects.publicChannel])
        } catch {
            let expectedReason = "Cannot trigger an event on multiple channels if any of them are encrypted."
            XCTAssertEqual(PusherError(from: error),
                           PusherError.invalidConfiguration(reason: expectedReason))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    // MARK: - POST batch event tests

    func testPostBatchEventsToChannelSucceedsForSingleChannelEvents() throws {
        let expectation = XCTestExpectation(function: #function)
        let testEvents = [TestObjects.encryptedEvent,
                          TestObjects.privateEvent,
                          TestObjects.publicEvent]
        Self.pusher.trigger(events: testEvents) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelInfoList in
                XCTAssertEqual(channelInfoList.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostBatchEventsToChannelFailsForTooLargeBatch() throws {
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        Batch too large (11 > 10)\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        let testEvents = [TestObjects.encryptedEvent,
                          TestObjects.privateEvent,
                          TestObjects.publicEvent,
                          TestObjects.encryptedEvent,
                          TestObjects.privateEvent,
                          TestObjects.publicEvent,
                          TestObjects.encryptedEvent,
                          TestObjects.privateEvent,
                          TestObjects.publicEvent,
                          TestObjects.encryptedEvent,
                          TestObjects.privateEvent]
        Self.pusher.trigger(events: testEvents) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostBatchEventsToChannelFailsForMultichannelEvents() throws {
        let expectation = XCTestExpectation(function: #function)
        let expectedErrorMessage = """
        Missing required parameter: channel\n
        """
        let expectedError = PusherError.failedResponse(statusCode: HTTPStatusCode.badRequest.rawValue,
                                                       errorResponse: expectedErrorMessage)
        let testEvents = [TestObjects.multichannelEvent]
        Self.pusher.trigger(events: testEvents) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
