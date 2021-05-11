import APIota
@testable import Pusher
import XCTest

final class AuthTokenTests: XCTestCase {

    private static let pusher = TestObjects.Client.shared

    func testAuthenticateEncryptedChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                6e964b22d03b1cfdecefded43be1a790a4c3ccf3c9bd272d25d98e55f742011b
                                """
        let expectedSharedSecret = "/0jEsqvKUTO4l9GSTmSMkBpz3UpsOqpRULThVmKVYHI="
        Self.pusher.authenticate(channel: TestObjects.Channels.encrypted,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { authToken in
                XCTAssertEqual(authToken.signature, expectedSignature)
                XCTAssertNil(authToken.userData)
                XCTAssertEqual(authToken.sharedSecret, expectedSharedSecret)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePrivateChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                750873f1478638c1142dce3165502c8d51b938a16239a47d600b4b42f83844bd
                                """
        Self.pusher.authenticate(channel: TestObjects.Channels.private,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { authToken in
                XCTAssertEqual(authToken.signature, expectedSignature)
                XCTAssertNil(authToken.userData)
                XCTAssertNil(authToken.sharedSecret)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePresenceChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                a97e9e91201b1fa8708c34c1eee3f48426668ba34d0989c324f96c0b0fd9971d
                                """
        let expectedUserData = "{\"user_id\":\"user_1\"}"
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId,
                                 userData: TestObjects.AuthSignatures.presenceAuthData) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { authToken in
                XCTAssertEqual(authToken.signature, expectedSignature)
                XCTAssertEqual(authToken.userData, expectedUserData)
                XCTAssertNil(authToken.sharedSecret)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePresenceChannelWithUserInfoSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                8c48fe056e1f200612891f232d0ff5bb5bbc08e63545664143a8db15c6555a46
                                """
        let expectedUserData = "{\"user_id\":\"user_1\",\"user_info\":{\"name\":\"Joe Bloggs\"}}"
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId,
                                 userData: TestObjects.AuthSignatures.presenceAuthDataWithUserInfo) { result in
            self.verifyAPIResultSuccess(result, expectation: expectation) { authToken in
                XCTAssertEqual(authToken.signature, expectedSignature)
                XCTAssertEqual(authToken.userData, expectedUserData)
                XCTAssertNil(authToken.sharedSecret)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePresenceChannelWithMissingUserDataFails() {
        let expectation = XCTestExpectation(function: #function)
        let authTokenServiceError = AuthTokenService.Error.missingUserDataForPresenceChannel
        let expectedError = PusherError.internalError(authTokenServiceError)
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePublicChannelFails() {
        let expectation = XCTestExpectation(function: #function)
        let authTokenServiceError = AuthTokenService.Error.authenticationAttemptForPublicChannel
        let expectedError = PusherError.internalError(authTokenServiceError)
        Self.pusher.authenticate(channel: TestObjects.Channels.public,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
