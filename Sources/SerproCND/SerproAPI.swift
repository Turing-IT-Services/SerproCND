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

    /// Authenticates the API and updates the access token.
    /// - Throws: `SerproError` if authentication fails.
    public func authenticate() async throws {
        do {
            let token = try await authService.authenticate()
            consultaService.updateAccessToken(token)
            logger.info("Authentication successful")
        } catch {
            logger.error("Authentication failed: \(error.localizedDescription)")
            throw error
        }
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
    public func consultaCND(tipoContribuinte: TipoContribuinte, contribuinteConsulta: String, codigoIdentificacao: String, gerarCertidaoPdf: Bool, chave: String? = nil) async throws -> [String: Any] {
        do {
            let response = try await consultaService.consultaCND(tipoContribuinte: tipoContribuinte, contribuinteConsulta: contribuinteConsulta, codigoIdentificacao: codigoIdentificacao, gerarCertidaoPdf: gerarCertidaoPdf, chave: chave)
            logger.info("Consulta CND successful")
            return response
        } catch {
            logger.error("Consulta CND failed: \(error.localizedDescription)")
            throw error
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
