import Foundation
import OSLog

class ConsultaCNPJService {
    private var accessToken: String?
    private let logger = Logger(subsystem: "com.turingits.SerproAPI", category: "consultaCNPJ")

    func updateAccessToken(_ token: String) {
        self.accessToken = token
    }

    /// Performs a CNPJ basic consultation.
    /// - Parameters:
    ///   - ni: The CNPJ number to be consulted.
    ///   - xSignature: Optional signature for timestamping.
    ///   - xRequestTag: Optional request tag for client identification.
    /// - Throws: `SerproError` if the consultation fails.
    /// - Returns: A dictionary containing the response data.
    func consultaCNPJBasico(ni: String, xSignature: String? = nil, xRequestTag: String? = nil) async throws -> [String: Any] {
        guard let token = accessToken else {
            logger.error("No access token available for consulta CNPJ")
            throw SerproError.noAccessToken
        }

        var urlComponents = URLComponents(string: "https://gateway.apiserpro.serpro.gov.br/cnpj/v2/basica/\(ni)")!
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let xSignature = xSignature {
            request.setValue(xSignature, forHTTPHeaderField: "x-signature")
        }
        
        if let xRequestTag = xRequestTag {
            request.setValue(xRequestTag, forHTTPHeaderField: "x-request-tag")
        }

        logger.debug("Sending consulta CNPJ request for ni: \(ni)")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            logger.error("Invalid response format during consulta CNPJ")
            throw SerproError.invalidResponse
        }

        if let status = json["status"] as? Int, status != 200 {
            let message = json["mensagem"] as? String ?? "Unknown error"
            logger.error("Consulta CNPJ failed with status \(status): \(message)")
            throw SerproError.serverError(status, message)
        }

        logger.info("Consulta CNPJ successful, response received")
        return json
    }
}
