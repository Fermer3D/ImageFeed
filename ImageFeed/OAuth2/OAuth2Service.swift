//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    private let urlSession = URLSession.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // Устранение гонки: если code такой же, как в текущем запросе — игнорируем вызов
        guard lastCode != code else {
            return
        }
        
        // Устранение гонки: если идет запрос с другим кодом — отменяем его
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = NetworkError.invalidRequest
            print("[OAuth2Service.fetchOAuthToken]: \(error) - Не удалось создать запрос")
            completion(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let data):
                    let token = data.accessToken
                    self.tokenStorage.token = token
                    
                    self.task = nil
                    // lastCode не зануляем, чтобы предотвратить повторный запрос с тем же кодом при успехе
                    
                    completion(.success(token))
                    
                case .failure(let error):
                    // Логирование в строгом соответствии с требованиями
                    self.logError(error)
                    
                    self.task = nil
                    self.lastCode = nil // При ошибке зануляем, чтобы дать возможность повторить попытку
                    
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func logError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code):
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - код ошибки \(code)")
            case .urlRequestError(let underlying):
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - ошибка запроса: \(underlying)")
            case .urlSessionError:
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - ошибка сессии")
            case .invalidRequest:
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - неверный запрос")
            case .decodingError(let decodingError):
                print("[OAuth2Service.fetchOAuthToken]: Decoding error - \(decodingError)")
            }
        } else {
            print("[OAuth2Service.fetchOAuthToken]: Unknown error - \(error.localizedDescription)")
        }
    }
}


