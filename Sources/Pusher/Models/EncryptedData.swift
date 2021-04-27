import Foundation

struct EncryptedData: Encodable {

    let nonce: String
    let ciphertext: String
}
