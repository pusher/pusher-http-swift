import APIota
@testable import Pusher
import XCTest

final class WebhookTests: XCTestCase {

    private static let pusher = TestObjects.pusher

    func testVerifyChannelOccupiedWebhookSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.channelOccupiedWebhookRequest) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { webhook in
                XCTAssertEqual(webhook.createdAt, Date(timeIntervalSince1970: 1619602993))
                XCTAssertEqual(webhook.events.count, 1)
                XCTAssertEqual(webhook.events.first!.eventType, .channelOccupied)
                XCTAssertEqual(webhook.events.first!.channelName, "my-channel")
                XCTAssertNil(webhook.events.first!.eventName)
                XCTAssertNil(webhook.events.first!.eventData)
                XCTAssertNil(webhook.events.first!.socketId)
                XCTAssertNil(webhook.events.first!.userId)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testVerifyChannelVacatedWebhookSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.channelVacatedWebhookRequest) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { webhook in
                XCTAssertEqual(webhook.createdAt, Date(timeIntervalSince1970: 1619602993))
                XCTAssertEqual(webhook.events.count, 1)
                XCTAssertEqual(webhook.events.first!.eventType, .channelVacated)
                XCTAssertEqual(webhook.events.first!.channelName, "my-channel")
                XCTAssertNil(webhook.events.first!.eventName)
                XCTAssertNil(webhook.events.first!.eventData)
                XCTAssertNil(webhook.events.first!.socketId)
                XCTAssertNil(webhook.events.first!.userId)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testVerifyMemberAddedWebhookSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.memberAddedWebhookRequest) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { webhook in
                XCTAssertEqual(webhook.createdAt, Date(timeIntervalSince1970: 1619602993))
                XCTAssertEqual(webhook.events.count, 1)
                XCTAssertEqual(webhook.events.first!.eventType, .memberAdded)
                XCTAssertEqual(webhook.events.first!.channelName, "presence-my-channel")
                XCTAssertEqual(webhook.events.first!.userId, "user_1")
                XCTAssertNil(webhook.events.first!.eventName)
                XCTAssertNil(webhook.events.first!.eventData)
                XCTAssertNil(webhook.events.first!.socketId)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testVerifyMemberRemovedWebhookSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.memberRemovedWebhookRequest) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { webhook in
                XCTAssertEqual(webhook.createdAt, Date(timeIntervalSince1970: 1619602993))
                XCTAssertEqual(webhook.events.count, 1)
                XCTAssertEqual(webhook.events.first!.eventType, .memberRemoved)
                XCTAssertEqual(webhook.events.first!.channelName, "presence-my-channel")
                XCTAssertEqual(webhook.events.first!.userId, "user_1")
                XCTAssertNil(webhook.events.first!.eventName)
                XCTAssertNil(webhook.events.first!.eventData)
                XCTAssertNil(webhook.events.first!.socketId)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testVerifyClientEventWebhookSucceeds() throws {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.clientEventWebhookRequest) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { webhook in
                XCTAssertEqual(webhook.createdAt, Date(timeIntervalSince1970: 1619602993))
                XCTAssertEqual(webhook.events.count, 1)
                XCTAssertEqual(webhook.events.first!.eventType, .clientEvent)
                XCTAssertEqual(webhook.events.first!.channelName, "my-channel")
                XCTAssertEqual(webhook.events.first!.eventName, "my-event")
                XCTAssertNotNil(webhook.events.first!.eventData)
                let decodedEventData = try? JSONDecoder().decode(MockEventData.self,
                                                            from: webhook.events.first!.eventData!)
                XCTAssertEqual(decodedEventData?.name, TestObjects.eventData.name)
                XCTAssertEqual(decodedEventData?.age, TestObjects.eventData.age)
                XCTAssertEqual(decodedEventData?.job, TestObjects.eventData.job)
                XCTAssertEqual(webhook.events.first!.socketId, "socket_1")
                XCTAssertNil(webhook.events.first!.userId)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testMissingPusherKeyHeaderWebhookFails() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.missingKeyHeaderWebhookRequest) { result in
            let expectedReason = """
            The '\(WebhookService.xPusherKeyHeader)' header is missing or invalid on the Webhook request.
            """
            let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testInvalidPusherKeyHeaderWebhookFails() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.invalidKeyHeaderWebhookRequest) { result in
            let expectedReason = """
            The '\(WebhookService.xPusherKeyHeader)' header is missing or invalid on the Webhook request.
            """
            let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testMissingPusherSignatureHeaderWebhookFails() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.missingSignatureHeaderWebhookRequest) { result in
            let expectedReason = """
            The '\(WebhookService.xPusherSignatureHeader)' header is missing or invalid on the Webhook request.
            """
            let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testInvalidPusherSignatureHeaderWebhookFails() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.invalidSignatureHeaderWebhookRequest) { result in
            let expectedReason = """
            The '\(WebhookService.xPusherSignatureHeader)' header is missing or invalid on the Webhook request.
            """
            let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testMissingBodyDataWebhookFails() {
        let expectation = XCTestExpectation(function: #function)
        Self.pusher.verifyWebhookRequest(TestObjects.missingBodyDataWebhookRequest) { result in
            let expectedReason = "Body data is missing on the Webhook request."
            let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
