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

    func consultaCND(tipoContribuinte: TipoContribuinte, contribuinteConsulta: String, codigoIdentificacao: String, gerarCertidaoPdf: Bool, chave: String? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let token = accessToken else {
            logger.error("No access token available for consulta CND")
            completion(.failure(SerproError.noAccessToken))
            return
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

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logger.error("Consulta CND failed: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                self.logger.error("No data received during consulta CND")
                completion(.failure(SerproError.noData))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = json["Status"] as? Int, status == 7, let chave = json["Chave"] as? String {
                        self.logger.info("Consulta CND in processing, key received")
                        completion(.failure(SerproError.processingKey(chave)))
                    } else if let status = json["Status"] as? Int, status != 1 {
                        let message = json["Messagem"] as? String ?? "Unknown error"
                        self.logger.error("Consulta CND failed with status \(status): \(message)")
                        completion(.failure(SerproError.serverError(status, message)))
                    } else {
                        self.logger.info("Consulta CND successful, response received")
                        completion(.success(json))
                    }
                } else {
                    self.logger.error("Invalid response format during consulta CND")
                    completion(.failure(SerproError.invalidResponse))
                }
            } catch {
                self.logger.error("Error parsing consulta CND response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
