import APIota
@testable import Pusher
import XCTest

final class ClientOptionsTests: XCTestCase {

    func testClientOptionsWithClusterSucceeds() {
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.appId, TestObjects.ClientOptions.testAppId)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.key, TestObjects.ClientOptions.testKey)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.secret, TestObjects.ClientOptions.testSecret)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.encryptionMasterKey, TestObjects.ClientOptions.testEncryptionMasterKey)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.cluster, TestObjects.ClientOptions.testCluster)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.host, "api-\(TestObjects.ClientOptions.testCluster).pusher.com")
        XCTAssertNil(TestObjects.ClientOptions.withCluster.httpProxy)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.port, 443)
        XCTAssertEqual(TestObjects.ClientOptions.withCluster.scheme, "https")
        XCTAssertTrue(TestObjects.ClientOptions.withCluster.useTLS)
    }

    func testClientOptionsWithCustomHostSucceeds() {
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.appId, TestObjects.ClientOptions.testAppId)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.key, TestObjects.ClientOptions.testKey)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.secret, TestObjects.ClientOptions.testSecret)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.encryptionMasterKey, TestObjects.ClientOptions.testEncryptionMasterKey)
        XCTAssertNil(TestObjects.ClientOptions.withCustomHost.cluster)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.host, TestObjects.ClientOptions.testCustomHost)
        XCTAssertNil(TestObjects.ClientOptions.withCustomHost.httpProxy)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.port, 443)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomHost.scheme, "https")
        XCTAssertTrue(TestObjects.ClientOptions.withCustomHost.useTLS)
    }

    func testClientOptionsWithCustomPortSucceeds() {
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.appId, TestObjects.ClientOptions.testAppId)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.key, TestObjects.ClientOptions.testKey)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.secret, TestObjects.ClientOptions.testSecret)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.encryptionMasterKey, TestObjects.ClientOptions.testEncryptionMasterKey)
        XCTAssertNil(TestObjects.ClientOptions.withCustomPort.cluster)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.host, TestObjects.ClientOptions.testCustomHost)
        XCTAssertNil(TestObjects.ClientOptions.withCustomPort.httpProxy)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.port, TestObjects.ClientOptions.testCustomPort)
        XCTAssertEqual(TestObjects.ClientOptions.withCustomPort.scheme, "https")
        XCTAssertFalse(TestObjects.ClientOptions.withCustomPort.useTLS)
    }

    func testClientOptionsWithInvalidEncryptionMasterKeyFails() {
        XCTAssertThrowsError(try PusherClientOptions(appId: TestObjects.ClientOptions.testAppId,
                                                     key: TestObjects.ClientOptions.testKey,
                                                     secret: TestObjects.ClientOptions.testSecret,
                                                     encryptionMasterKey: TestObjects.ClientOptions.invalidEncryptionMasterKey)) { error in
            let expectedReason = "The provided 'encryptionMasterKeyBase64' value is not a valid Base-64 string."
            XCTAssertEqual(error as! PusherError, .invalidConfiguration(reason: expectedReason))
        }
    }

    func testClientOptionsWithInvalidPrefixCustomHostFails() {
        XCTAssertThrowsError(try PusherClientOptions(appId: TestObjects.ClientOptions.testAppId,
                                                     key: TestObjects.ClientOptions.testKey,
                                                     secret: TestObjects.ClientOptions.testSecret,
                                                     encryptionMasterKey: TestObjects.ClientOptions.testEncryptionMasterKey,
                                                     host: TestObjects.ClientOptions.invalidPrefixCustomHost)) { error in
            let expectedReason = "The provided 'host' value should not have a 'https://' or 'http://' prefix."
            XCTAssertEqual(error as! PusherError, .invalidConfiguration(reason: expectedReason))
        }
    }

    func testClientOptionsWithInvalidSuffixCustomHostFails() {
        XCTAssertThrowsError(try PusherClientOptions(appId: TestObjects.ClientOptions.testAppId,
                                                     key: TestObjects.ClientOptions.testKey,
                                                     secret: TestObjects.ClientOptions.testSecret,
                                                     encryptionMasterKey: TestObjects.ClientOptions.testEncryptionMasterKey,
                                                     host: TestObjects.ClientOptions.invalidSuffixCustomHost)) { error in
            let expectedReason =  "The provided 'host' value should not have a '/' suffix."
            XCTAssertEqual(error as! PusherError, .invalidConfiguration(reason: expectedReason))
        }
    }

    func testClientOptionsWithCustomPortAndMissingCustomHostFails() {
        XCTAssertThrowsError(try PusherClientOptions(appId: TestObjects.ClientOptions.testAppId,
                                                     key: TestObjects.ClientOptions.testKey,
                                                     secret: TestObjects.ClientOptions.testSecret,
                                                     encryptionMasterKey: TestObjects.ClientOptions.testEncryptionMasterKey,
                                                     port: TestObjects.ClientOptions.testCustomPort)) { error in
            let expectedReason =  "A 'host' should be provided if a custom 'port' or 'scheme' is set."
            XCTAssertEqual(error as! PusherError, .invalidConfiguration(reason: expectedReason))
        }
    }
}
