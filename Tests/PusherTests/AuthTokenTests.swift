import APIota
@testable import Pusher
import XCTest

final class AuthTokenTests: XCTestCase {

    private static let pusher = TestObjects.pusher

    func testAuthenticateEncryptedChannelSucceeds() {
        let expectation = XCTestExpectation(function: #function)
        let expectedSignature = "b5390e69136683c40d2d:215d060a09b11d609dd6640ebe89a9ec256eea269a75a8a5474e5b598e12e214"
        let expectedSharedSecret = "FF3Dmpan4Q6fa/lZ2iO3/+LEFWH1D2g/InoQyL4y+sk="
        Self.pusher.authenticate(channel: TestObjects.encryptedChannel,
                                 socketId: TestObjects.socketId) { result in
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
        let expectedSignature = "b5390e69136683c40d2d:077ffe22dd122b1752d77a3fac2a4d53a08f9e5e19799e9266e7b243bc619100"
        Self.pusher.authenticate(channel: TestObjects.privateChannel,
                                 socketId: TestObjects.socketId) { result in
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
        let expectedSignature = "b5390e69136683c40d2d:9f80a404199ac45a69b836a25fc88f09efb9ffef44d6fded36ac91b9d10887a2"
        let expectedUserData = "{\"user_id\":\"user_1\"}"
        Self.pusher.authenticate(channel: TestObjects.presenceChannel,
                                 socketId: TestObjects.socketId,
                                 userData: TestObjects.presenceAuthData) { result in
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
        let expectedSignature = "b5390e69136683c40d2d:7709a34e0bd1f12fcadb52d9cc85feebfef414e59166a357bf777c4043c6aa5e"
        // swiftlint:disable:next line_length
        let expectedUserData = "{\"user_id\":\"user_1\",\"user_info\":{\"name\":\"Joe Bloggs\"}}"
        Self.pusher.authenticate(channel: TestObjects.presenceChannel,
                                 socketId: TestObjects.socketId,
                                 userData: TestObjects.presenceAuthDataWithUserInfo) { result in
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
        let expectedReason = """
        Auth token generation failed with error: \
        Authenticating presence channel subscriptions requires 'userData'.
        """
        let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
        Self.pusher.authenticate(channel: TestObjects.presenceChannel,
                                 socketId: TestObjects.socketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func testAuthenticatePublicChannelFails() {
        let expectation = XCTestExpectation(function: #function)
        let expectedReason = """
        Auth token generation failed with error: \
        Authenticating public channel subscriptions is not required.
        """
        let expectedError = PusherError.invalidConfiguration(reason: expectedReason)
        Self.pusher.authenticate(channel: TestObjects.publicChannel,
                                 socketId: TestObjects.socketId) { result in
            self.verifyAPIResultFailure(result, expectation: expectation, expectedError: expectedError)
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
