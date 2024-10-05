//
//  AuthService.swift
//  SerproCND
//
//  Created by Murilo Araujo on 05/10/24.
//

import Foundation
import OSLog

class AuthService {
    private let consumerKey: String
    private let consumerSecret: String
    private let logger = Logger(subsystem: "com.yourcompany.SerproAPI", category: "auth")

    init(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }

    /// Authenticates the service and returns an access token.
    /// - Throws: `SerproError` if authentication fails.
    /// - Returns: A string containing the access token.
    func authenticate() async throws -> String {
        let credentials = "\(consumerKey):\(consumerSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            throw SerproError.invalidCredentials
        }

        let base64Credentials = credentialsData.base64EncodedString()
        var request = URLRequest(url: URL(string: "https://gateway.apiserpro.serpro.gov.br/token")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        logger.debug("Sending authentication request")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let token = json["access_token"] as? String else {
            logger.error("Invalid response format during authentication")
            throw SerproError.invalidResponse
        }

        logger.info("Authentication successful, token received")
        return token
    }
}
