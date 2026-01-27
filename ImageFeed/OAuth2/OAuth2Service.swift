//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    
    private(set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = authTokenRequest(code: code)
        
        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    // Декодируем ответ. Ключи в JSON (snake_case) можно сопоставить автоматически
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    self?.authToken = body.accessToken
                    completion(.success(body.accessToken))
                } catch {
                    print("⚠️ Ошибка декодирования: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("⚠️ Сетевая ошибка: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

// MARK: - Helpers
private extension OAuth2Service {
    func authTokenRequest(code: String) -> URLRequest {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        return request
    }
}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
