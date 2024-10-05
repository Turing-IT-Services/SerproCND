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

    func authenticate(completion: @escaping (Result<String, Error>) -> Void) {
        let credentials = "\(consumerKey):\(consumerSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            completion(.failure(SerproError.invalidCredentials))
            return
        }

        let base64Credentials = credentialsData.base64EncodedString()
        var request = URLRequest(url: URL(string: "https://gateway.apiserpro.serpro.gov.br/token")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)

        logger.debug("Sending authentication request")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logger.error("Authentication failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                self.logger.error("No data received during authentication")
                completion(.failure(SerproError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    self.logger.info("Authentication successful, token received")
                    completion(.success(token))
                } else {
                    self.logger.error("Invalid response format during authentication")
                    completion(.failure(SerproError.invalidResponse))
                }
            } catch {
                self.logger.error("Error parsing authentication response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
