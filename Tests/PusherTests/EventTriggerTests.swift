import APIota
@testable import Pusher
import XCTest

final class EventTriggerTests: XCTestCase {

    private static let pusher = TestObjects.Client.shared

    // MARK: - POST single event tests

    func testPostEventToChannelSucceedsForEncryptedChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.Events.encrypted) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForPrivateChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.Events.private) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForPublicChannel() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.Events.public) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { channelSummaries in
                XCTAssertEqual(channelSummaries.count, 0)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testPostEventToChannelSucceedsForValidMultichannelEvent() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.trigger(event: TestObjects.Events.multichannel) { result in
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
                          eventData: TestObjects.Events.eventData,
                          channels: [TestObjects.Channels.encrypted,
                                     TestObjects.Channels.public])
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
        let testEvents = [TestObjects.Events.encrypted,
                          TestObjects.Events.private,
                          TestObjects.Events.public]
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
        let testEvents = [TestObjects.Events.encrypted,
                          TestObjects.Events.private,
                          TestObjects.Events.public,
                          TestObjects.Events.encrypted,
                          TestObjects.Events.private,
                          TestObjects.Events.public,
                          TestObjects.Events.encrypted,
                          TestObjects.Events.private,
                          TestObjects.Events.public,
                          TestObjects.Events.encrypted,
                          TestObjects.Events.private]
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
        let testEvents = [TestObjects.Events.multichannel]
        Self.pusher.trigger(events: testEvents) { result in
            self.verifyAPIResultFailure(result,
                                        expectation: expectation,
                                        expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
