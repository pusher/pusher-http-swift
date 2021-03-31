import Crypto
import Foundation
import TweetNacl

/// Provides cryptography functionality as a collection of helper methods.
struct Crypto {

    /// An error generated during a cryptographic operation.
    enum CryptoError: LocalizedError {

        /// Generation of random bytes failed with a `OSStatus` code.
        case randomBytesGenerationError(statusCode: OSStatus)

        /// Zero random bytes were requested.
        case zeroRandomBytesRequested

        /// A localized human-readable description of the error.
        public var errorDescription: String? {
            switch self {
            case .randomBytesGenerationError(statusCode: let code):
                return NSLocalizedString("Generating random bytes failed with error: \(code).",
                                         comment: "'CryptoError.randomBytesGenerationError' error text")

            case .zeroRandomBytesRequested:
                return NSLocalizedString("Zero random bytes were requested.",
                                         comment: "'CryptoError.zeroRandomBytesRequested' error text")
            }
        }
    }

    /// Generates a SHA256 HMAC digest of a `string` using a `secret`.
    /// - Parameters:
    ///   - secret: The secret key.
    ///   - string: The `String` to use as source data.
    /// - Returns: The SHA256 HMAC `String`, in hexadecimal notation.
    static func generateSHA256HMAC(secret: String, string: String) -> String {

        let key = SymmetricKey(data: Data(secret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: Data(string.utf8), using: key)

        return signature
            .map { String(format: "%02hhx", $0) }
            .joined()
    }

    /// Generates a MD5 digest of some data.
    /// - Parameter data: The source `Data` to encode.
    /// - Returns: The MD5 digest `String`, in hexadecimal notation.
    static func generateMD5Digest(data: Data) -> String {

        let digest = Insecure.MD5.hash(data: data)

        return digest
            .map { String(format: "%02hhx", $0) }
            .joined()
    }

    /// Encrypt a `string` using a `key`, according to the
    /// [Secretbox standard](https://nacl.cr.yp.to/secretbox.html) from NaCl.
    /// - Parameters:
    ///   - string: The data `String` to encrypt.
    ///   - key: The key `String` to use for the encryption operation.
    /// - Throws: An `Error` if the encryption operation fails for some reason.
    /// - Returns: The encrypted data (as a `String`), if the operation was successful.
    static func encrypt(string: String, key: String) throws -> String? {

        let nonce = try secureRandomBytes(count: 24)
        let secretBox = try NaclSecretBox.secretBox(message: Data(string.utf8),
                                                    nonce: nonce,
                                                    key: Data(key.utf8))

        return String(data: secretBox, encoding: .utf8)
    }

    // MARK: - Private methods

    /// Generates cryptographically secure random bytes.
    /// - Parameter count: The number of random bytes to return.
    /// - Throws: An `Error` if the random bytes could not be generated for some reason,
    ///           or if zero random bytes were requested.
    /// - Returns: The requested number of cryptographically secure random bytes, as `Data`.
    private static func secureRandomBytes(count: Int) throws -> Data {

        // Generation method is platform dependent
        // (The Security framework is only available on Apple platforms).
        #if os(Linux)

        var bytes = [UInt8]()
        for _ in 0..<count {
            let randomByte = UInt8.random(in: UInt8.min...UInt8.max)
            bytes.append(randomByte)
        }
        let randomData = Data(bytes: &bytes, count: count)

        return randomData

        #else

        var randomData = Data(count: count)
        let result = try randomData.withUnsafeMutableBytes { bufferPointer -> Int32 in
            guard let baseAddress = bufferPointer.baseAddress else {
                throw CryptoError.zeroRandomBytesRequested
            }

            return SecRandomCopyBytes(kSecRandomDefault, count, baseAddress)
        }

        guard result == errSecSuccess else {
            throw CryptoError.randomBytesGenerationError(statusCode: result)
        }

        return randomData

        #endif
    }
}
