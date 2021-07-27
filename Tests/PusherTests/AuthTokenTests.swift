import APIota
@testable import Pusher
import XCTest

final class AuthTokenTests: XCTestCase {

    private static let pusher = TestObjects.Client.shared

    func testAuthenticateEncryptedChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = """
                                \(TestObjects.Client.testKey):\
                                c58902aaef1a2c0dd8f0487c889c1bdccfe22cb32fd16b93215350291b18ecf4
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
                                1b79c61f9d86d532b0cb82dc7e301696497eaba58855e831e7030afd8e76ac86
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
                                ca63b86e1b51b8dc5592a141471c487523063ab89cd75e6b867bf6b0c567b1a8
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
                                89c5b5af5e845494ed9f230b6b7585ba9ebd8c42d2408ea155e7e5d44422e2ca
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
