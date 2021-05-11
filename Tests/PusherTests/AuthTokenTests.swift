import APIota
@testable import Pusher
import XCTest

final class AuthTokenTests: XCTestCase {

    private static let pusher = TestObjects.Client.shared

    func testAuthenticateEncryptedChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                222dfced2d1e7b39bcbc5e4f43402a9522acddb385d49a6452881bd6db7fa9f2
                                """
        let expectedSharedSecret = "AcTnN9VKpzSSjPwqb/7Y3U0qlO2ySQQUbvTPW2O4ERI="
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
                                e367fbe4d2ae2598b191acc02d3530f73731cbe1b8da5d5041cdae7a847c0977
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
                                cab92b812ec57f7afa43e8778e666fb6fbd5329b2ea8e6d5d0d60b9831406c3a
                                """
        let expectedUserData = "{\"user_id\":\"user_1\"}"
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId,
                                 userData: TestObjects.AuthSignatures.presenceUserData) { result in
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
                                99ea557326f7977d2955151d413e3002a1192f47046dec5c77c441a81e7fc9b3
                                """
        let expectedUserData = "{\"user_id\":\"user_1\",\"user_info\":{\"name\":\"Joe Bloggs\"}}"
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId,
                                 userData: TestObjects.AuthSignatures.presenceUserDataWithUserInfo) { result in
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
        let authTokenServiceError = AuthenticationTokenService.Error.missingUserDataForPresenceChannel
        let expectedError = PusherError.internalError(authTokenServiceError)
        Self.pusher.authenticate(channel: TestObjects.Channels.presence,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePublicChannelFails() {
        let expectation = XCTestExpectation(function: #function)
        let authTokenServiceError = AuthenticationTokenService.Error.authenticationAttemptForPublicChannel
        let expectedError = PusherError.internalError(authTokenServiceError)
        Self.pusher.authenticate(channel: TestObjects.Channels.public,
                                 socketId: TestObjects.AuthSignatures.testSocketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
