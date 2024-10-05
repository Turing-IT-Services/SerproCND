//
//  SerproAPI.swift
//  SerproCND
//
//  Created by Murilo Araujo on 05/10/24.
//
import Foundation
import OSLog

public struct SerproAPI {
    private let authService: AuthService
    private let consultaService: ConsultaCNDService
    private let logger = Logger(subsystem: "com.yourcompany.SerproAPI", category: "network")

    public init(consumerKey: String, consumerSecret: String) {
        self.authService = AuthService(consumerKey: consumerKey, consumerSecret: consumerSecret)
        self.consultaService = ConsultaCNDService()
    }

    public func authenticate(completion: @escaping (Result<Void, Error>) -> Void) {
        authService.authenticate { result in
            switch result {
            case .success(let token):
                self.consultaService.updateAccessToken(token)
                self.logger.info("Authentication successful")
                completion(.success(()))
            case .failure(let error):
                self.logger.error("Authentication failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    public func consultaCND(tipoContribuinte: TipoContribuinte, contribuinteConsulta: String, codigoIdentificacao: String, gerarCertidaoPdf: Bool, chave: String? = nil, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        consultaService.consultaCND(tipoContribuinte: tipoContribuinte, contribuinteConsulta: contribuinteConsulta, codigoIdentificacao: codigoIdentificacao, gerarCertidaoPdf: gerarCertidaoPdf, chave: chave) { result in
            switch result {
            case .success(let response):
                self.logger.info("Consulta CND successful")
                completion(.success(response))
            case .failure(let error):
                self.logger.error("Consulta CND failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

public enum TipoContribuinte: Int {
    case pessoaJuridica = 1
    case pessoaFisica = 2
    case imovelRural = 3
}

public enum SerproError: Error {
    case invalidCredentials
    case noData
    case invalidResponse
    case noAccessToken
    case processingKey(String)
    case serverError(Int, String)
}
