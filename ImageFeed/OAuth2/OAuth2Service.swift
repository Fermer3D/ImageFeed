//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import Foundation

final class OAuth2Service {
   
    static let shared = OAuth2Service()
    private init() {}
    
    
    private let urlSession = URLSession.shared
    private let storage = OAuth2TokenStorage()
    
    private(set) var authToken: String? {
        get { storage.token }
        set { storage.token = newValue }
    }
    
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = authTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                   
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    self?.authToken = body.accessToken
                    completion(.success(body.accessToken))
                    
                    print("✅ [OAuth2Service]: Токен успешно получен и распарсен")
                } catch {
                    print("❌ [OAuth2Service]: Ошибка декодирования — \(error)")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("❌ [OAuth2Service]: Сетевая ошибка — \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}


private extension OAuth2Service {
    func authTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
