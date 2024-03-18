//
//  LoginQRProvider.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 5/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import Combine
import PIALibrary

class LoginQRProvider: ValidateLoginQRCodeProviderType {
    private let httpClient: HTTPClientType
    private let urlRequestMaker: LoginQRURLRequestMaker
    private let domainMapper: LoginQRCodeDomainMapper
    private let errorMapper: LoginQRErrorMapper
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>?
    private var cancellable: Cancellable?
    
    init(httpClient: HTTPClientType, urlRequestMaker: LoginQRURLRequestMaker, domainMapper: LoginQRCodeDomainMapper, errorMapper: LoginQRErrorMapper) {
        self.httpClient = httpClient
        self.urlRequestMaker = urlRequestMaker
        self.domainMapper = domainMapper
        self.errorMapper = errorMapper
    }
    
    func validateLoginQRCodeToken(_ qrCodeToken: LoginQRCode) async throws -> UserToken {
        return try await withCheckedThrowingContinuation { continuation in
            validateLoginQRCodeToken(qrCodeToken) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                    case let .success(userToken):
                        continuation.resume(returning: userToken)
                    case let .failure(error):
                        continuation.resume(throwing: errorMapper.map(error: error))
                }
            }
        }
    }
    
    private func stopTimer() {
        cancellable?.cancel()
        timer = nil
    }
    
    private func validateLoginQRCodeToken(_ qrCodeToken: LoginQRCode, completion: @escaping (Result<UserToken, ClientError>) -> Void) {
        let urlRequest = urlRequestMaker.makeValidateLoginQRURLRequest(loginQRToken: qrCodeToken.token)

        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        cancellable = timer?.sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            Task {
                do {
                    let userTokenDTO = try await self.validateLoginQRCodeToken(urlRequest: urlRequest)
                    self.stopTimer()
                    
                    guard let userToken = self.domainMapper.map(dto: userTokenDTO) else {
                        completion(.failure(ClientError.malformedResponseData))
                        return
                    }
                    
                    completion(.success(userToken))
                } catch {
                    if qrCodeToken.expiresAt.timeIntervalSinceNow <= 0 {
                        self.stopTimer()
                        completion(.failure(ClientError.expired))
                    }
                }
            }
        })
    }
    
    private func validateLoginQRCodeToken(urlRequest: URLRequest) async throws -> UserTokenDTO {
        do {
            let data = try await httpClient.makeRequest(request: urlRequest)
            guard let userTokenDTO = try? JSONDecoder().decode(UserTokenDTO.self, from: data) else {
                throw ClientError.malformedResponseData
            }
            
            return userTokenDTO
        } catch {
            throw error
        }
    }
    
    deinit {
        stopTimer()
    }
}

extension LoginQRProvider: GenerateLoginQRCodeProviderType {
    func generateLoginQRCodeToken() async throws -> LoginQRCode {
        let urlRequest = urlRequestMaker.makeGenerateLoginQRURLRequest()
        do {
            let data = try await httpClient.makeRequest(request: urlRequest)
            
            guard let loginQRTokenDTO = try? JSONDecoder().decode(LoginQRTokenDTO.self, from: data),
                  let loginQRCode = self.domainMapper.map(dto: loginQRTokenDTO) else {
                throw ClientError.malformedResponseData
            }
            
            return loginQRCode
        } catch {
            throw error
        }
    }
}
