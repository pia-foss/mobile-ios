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
    private let generateQRLogin: GenerateQRLoginUseCaseType
    private let accountProvider: AccountProvider
    
    init(httpClient: HTTPClientType, urlRequestMaker: LoginQRURLRequestMaker, domainMapper: LoginQRCodeDomainMapper, errorMapper: LoginQRErrorMapper, generateQRLogin: GenerateQRLoginUseCaseType, accountProvider: AccountProvider) {
        self.httpClient = httpClient
        self.urlRequestMaker = urlRequestMaker
        self.domainMapper = domainMapper
        self.errorMapper = errorMapper
        self.generateQRLogin = generateQRLogin
        self.accountProvider = accountProvider
    }
    
    func validateLoginQRCodeToken(_ qrCodeToken: LoginQRCode) async throws -> String {
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
    
    private func validateLoginQRCodeToken(_ qrCodeToken: LoginQRCode, completion: @escaping (Result<String, ClientError>) -> Void) {
        var isValidating = false
        
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
        cancellable = timer?.sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            if isValidating { return }
            isValidating = true
            
            accountProvider.validateLoginQR(with: qrCodeToken.token) { [weak self] apiToken, error in
                guard let self = self else { return }
                
                if let apiToken {
                    self.stopTimer()
                    completion(.success(apiToken))
                    return
                } else {
                    if qrCodeToken.expiresAt.timeIntervalSinceNow <= 0 {
                        if self.timer != nil {
                            completion(.failure(ClientError.expired))
                        }
                        self.stopTimer()
                    }
                }
                isValidating = false
            }
        })
    }
    
    deinit {
        stopTimer()
    }
}

extension LoginQRProvider: GenerateLoginQRCodeProviderType {
    func generateLoginQRCodeToken() async throws -> LoginQRCode {
        do {
            let data = try await withCheckedThrowingContinuation { continuation in
                generateQRLogin { result in
                    switch result {
                        case let .success(data):
                            continuation.resume(returning: data)
                        case let .failure(error):
                            continuation.resume(throwing: error)
                    }
                }
            }
            
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
