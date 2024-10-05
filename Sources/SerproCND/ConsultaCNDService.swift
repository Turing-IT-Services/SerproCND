//
//  ConsultaCNDService.swift
//  SerproCND
//
//  Created by Murilo Araujo on 05/10/24.
//

import Foundation
import OSLog

class ConsultaCNDService {
    private var accessToken: String?
    private let logger = Logger(subsystem: "com.yourcompany.SerproAPI", category: "consulta")

    func updateAccessToken(_ token: String) {
        self.accessToken = token
    }

    /// Performs a CND consultation.
    /// - Parameters:
    ///   - tipoContribuinte: The type of taxpayer.
    ///   - contribuinteConsulta: The taxpayer being consulted.
    ///   - codigoIdentificacao: The identification code.
    ///   - gerarCertidaoPdf: Whether to generate a PDF certificate.
    ///   - chave: An optional key.
    /// - Throws: `SerproError` if the consultation fails.
    /// - Returns: A dictionary containing the response data.
    func consultaCND(tipoContribuinte: TipoContribuinte, contribuinteConsulta: String, codigoIdentificacao: String, gerarCertidaoPdf: Bool, chave: String? = nil) async throws -> [String: Any] {
        guard let token = accessToken else {
            logger.error("No access token available for consulta CND")
            throw SerproError.noAccessToken
        }

        var request = URLRequest(url: URL(string: "https://gateway.apiserpro.serpro.gov.br/consulta-cnd-trial/v1/certidao")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "TipoContribuinte": tipoContribuinte.rawValue,
            "ContribuinteConsulta": contribuinteConsulta,
            "CodigoIdentificacao": codigoIdentificacao,
            "GerarCertidaoPdf": gerarCertidaoPdf
        ]

        if let chave = chave {
            body["Chave"] = chave
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        logger.debug("Sending consulta CND request with body: \(body)")

        let (data, _) = try await URLSession.shared.data(for: request)

        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            logger.error("Invalid response format during consulta CND")
            throw SerproError.invalidResponse
        }

        if let status = json["Status"] as? Int, status == 7, let chave = json["Chave"] as? String {
            logger.info("Consulta CND in processing, key received")
            throw SerproError.processingKey(chave)
        } else if let status = json["Status"] as? Int, status != 1 {
            let message = json["Messagem"] as? String ?? "Unknown error"
            logger.error("Consulta CND failed with status \(status): \(message)")
            throw SerproError.serverError(status, message)
        }

        logger.info("Consulta CND successful, response received")
        return json
    }
}
