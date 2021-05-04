import Foundation

/// Provides functionality for verifying the authenticity of received Webhook requests,
/// and for decoding the request into a `Webhook` object.
struct WebhookService {

    /// The `X-Pusher-Key` header.
    static let xPusherKeyHeader = "X-Pusher-Key"

    /// The `X-Pusher-Signature` header.
    static let xPusherSignatureHeader = "X-Pusher-Signature"

    /// Verify that the key and signature header values of the received Webhook request are valid.
    /// - Parameters:
    ///   - request: The received `URLRequest` representing a Webhook.
    ///   - callback: A closure containing a `Result` that is populated with an error
    ///   - options: Configuration options used to managing the connection.
    /// - Throws: A `PusherError` if the key or signature is invalid.
    static func verifySignature(of request: URLRequest,
                                using options: PusherClientOptions) throws {

        // Verify the Webhook key and signature header values are valid
        guard let xPusherKeyHeaderValue = request.value(forHTTPHeaderField: xPusherKeyHeader),
              xPusherKeyHeaderValue == options.key else {
            let reason = "The '\(xPusherKeyHeader)' header is missing or invalid on the Webhook request."
            throw PusherError.invalidConfiguration(reason: reason)
        }

        guard let bodyData = request.httpBody, bodyData.count > 0 else {
            let reason = "Body data is missing on the Webhook request."
            throw PusherError.invalidConfiguration(reason: reason)
        }

        let expectedSignature = CryptoService.sha256HMAC(for: bodyData,
                                                         using: options.secret.toData()).hexEncodedString()
        guard let xPusherSignatureHeaderValue = request.value(forHTTPHeaderField: xPusherSignatureHeader),
              expectedSignature == xPusherSignatureHeaderValue else {
            let reason = "The '\(xPusherSignatureHeader)' header is missing or invalid on the Webhook request."
            throw PusherError.invalidConfiguration(reason: reason)
        }
    }

    /// Decodes a `Webhook` from a received Webhook request.
    ///
    /// Any encrypted events on the Webhook request will be decrypted before returning.
    /// - Parameter request: The received `URLRequest` representing a Webhook.
    /// - Parameter options: Configuration options used to managing the connection.
    /// - Throws: A `PusherError` if the decoding operation failed for some reason.
    /// - Returns: A decoded `Webhook` object.
    static func webhook(from request: URLRequest, using options: PusherClientOptions) throws -> Webhook {
        let decoder = JSONDecoder()
        let webhook = try decoder.decode(Webhook.self, from: request.httpBody!)

        let webhookEvents = try webhook.events.map { webhookEvent -> WebhookEvent in
            try webhookEvent.decrypted(using: options)
        }

        return Webhook(createdAt: webhook.createdAt, events: webhookEvents)
    }
}
