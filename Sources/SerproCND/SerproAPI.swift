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
    private let consultaCNDService: ConsultaCNDService
    private let consultaCPFService: ConsultaCPFService
    private let consultaCNPJService: ConsultaCNPJService
    private let logger = Logger(subsystem: "com.turingits.SerproAPI", category: "network")

    public init(consumerKey: String, consumerSecret: String) {
        self.authService = AuthService(consumerKey: consumerKey, consumerSecret: consumerSecret)
        self.consultaCNDService = ConsultaCNDService()
        self.consultaCPFService = ConsultaCPFService()
        self.consultaCNPJService = ConsultaCNPJService()
    }

    public func authenticate() async throws {
        do {
            let token = try await authService.authenticate()
            consultaCNDService.updateAccessToken(token)
            consultaCPFService.updateAccessToken(token)
            consultaCNPJService.updateAccessToken(token)
            logger.info("Authentication successful")
        } catch {
            logger.error("Authentication failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func consultaCND(tipoContribuinte: TipoContribuinte, contribuinteConsulta: String, codigoIdentificacao: String, gerarCertidaoPdf: Bool, chave: String? = nil) async throws -> [String: Any] {
        do {
            let response = try await consultaCNDService.consultaCND(tipoContribuinte: tipoContribuinte, contribuinteConsulta: contribuinteConsulta, codigoIdentificacao: codigoIdentificacao, gerarCertidaoPdf: gerarCertidaoPdf, chave: chave)
            logger.info("Consulta CND successful")
            return response
        } catch {
            logger.error("Consulta CND failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func consultaCPF(ni: String, xSignature: String? = nil, xRequestTag: String? = nil) async throws -> [String: Any] {
        do {
            let response = try await consultaCPFService.consultaCPF(ni: ni, xSignature: xSignature, xRequestTag: xRequestTag)
            logger.info("Consulta CPF successful")
            return response
        } catch {
            logger.error("Consulta CPF failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func consultaCNPJBasico(ni: String, xSignature: String? = nil, xRequestTag: String? = nil) async throws -> [String: Any] {
        do {
            let response = try await consultaCNPJService.consultaCNPJBasico(ni: ni, xSignature: xSignature, xRequestTag: xRequestTag)
            logger.info("Consulta CNPJ Basico successful")
            return response
        } catch {
            logger.error("Consulta CNPJ Basico failed: \(error.localizedDescription)")
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
