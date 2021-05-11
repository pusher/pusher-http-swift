import Crypto
import Foundation
import TweetNacl

/// Provides cryptography functionality for generating digests, HMACs
/// and encrypting and decrypting data according to the
/// [Secretbox standard](https://nacl.cr.yp.to/secretbox.html) from NaCl.
struct CryptoService {

    // MARK: - Error reporting

    /// An error generated during a cryptographic operation.
    enum Error: LocalizedError {

        /// An error occurred during a NaCl cryptographic operation.
        case naclError(_ error: Swift.Error)

        /// Generation of random bytes failed with a `OSStatus` code.
        case randomBytesGenerationError(statusCode: OSStatus)

        /// Zero random bytes were requested.
        case zeroRandomBytesRequested

        /// A localized human-readable description of the error.
        public var errorDescription: String? {
            switch self {
            case .naclError(error: let error):
                return NSLocalizedString("A cryptographic operation failed with error: \(error.localizedDescription)",
                                         comment: "'.naclError' error text")

            case .randomBytesGenerationError(statusCode: let code):
                return NSLocalizedString("Generating random bytes failed with error: \(code).",
                                         comment: "'.randomBytesGenerationError' error text")

            case .zeroRandomBytesRequested:
                return NSLocalizedString("Zero random bytes were requested.",
                                         comment: "'.zeroRandomBytesRequested' error text")
            }
        }
    }

    // MARK: - Hashing algorithms

    /// Generates a MD5 digest of some data.
    /// - Parameter data: The source `Data` to hash.
    /// - Returns: The MD5 digest `Data`.
    static func md5Digest(data: Data) -> Data {

        return Data(Insecure.MD5.hash(data: data))
    }

    /// Generates a SHA256 digest of some data.
    /// - Parameter data: The source `Data` to hash.
    /// - Returns: The SHA256 digest `Data`.
    static func sha256Digest(data: Data) -> Data {

        return Data(SHA256.hash(data: data))
    }

    // MARK: - Hash-based message authentication

    /// Generates a SHA256 HMAC digest of a `string` using a `secret`.
    /// - Parameters:
    ///   - data: The source `Data` for the computation.
    ///   - key: The symmetric key used to secure the computation.
    /// - Returns: The SHA256 HMAC digest `Data`.
    static func sha256HMAC(for data: Data, using key: Data) -> Data {

        let key = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)

        return Data(signature)
    }

    // MARK: - NaCl-based encryption and decryption

    /// Decrypt some `data` using a `nonce` and a `key`, according to the
    /// [Secretbox standard](https://nacl.cr.yp.to/secretbox.html) from NaCl.
    /// - Parameters:
    ///   - data: The encrypted `Data` to decrypt.
    ///   - nonce: The nonce `Data` to use for the decryption operation.
    ///   - key: The key `Data` to use for the decryption operation.
    /// - Throws: An `CryptoError` if the decryption operation fails for some reason.
    /// - Returns: The decrypted `Data`, if the operation was successful.
    static func decrypt(data: Data, nonce: Data, key: Data) throws -> Data {

        do {
            return try NaclSecretBox.open(box: data, nonce: nonce, key: key)
        } catch {
            throw Error.naclError(error)
        }
    }

    /// Encrypt some `data` using a `nonce` and a `key`, according to the
    /// [Secretbox standard](https://nacl.cr.yp.to/secretbox.html) from NaCl.
    /// - Parameters:
    ///   - data: The `Data` to encrypt.
    ///   - nonce: The nonce `Data` to use for the encryption operation.
    ///   - key: The key `Data` to use for the encryption operation.
    /// - Throws: An `CryptoError` if the encryption operation fails for some reason.
    /// - Returns: The encrypted `Data`, if the operation was successful.
    static func encrypt(data: Data, nonce: Data, key: Data) throws -> Data {

        do {
            return try NaclSecretBox.secretBox(message: data, nonce: nonce, key: key)
        } catch {
            throw Error.naclError(error)
        }
    }

    // MARK: - Random data

    /// Generates cryptographically secure random data.
    /// - Parameter count: The number of random bytes to return.
    /// - Throws: An `CryptoError` if the random data could not be generated for some reason,
    ///           or if zero random bytes were requested.
    /// - Returns: The requested number of cryptographically secure random bytes, as `Data`.
    static func secureRandomData(count: Int) throws -> Data {

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
                throw Error.zeroRandomBytesRequested
            }

            return SecRandomCopyBytes(kSecRandomDefault, count, baseAddress)
        }

        guard result == errSecSuccess else {
            throw Error.randomBytesGenerationError(statusCode: result)
        }

        return randomData

        #endif
    }
}
