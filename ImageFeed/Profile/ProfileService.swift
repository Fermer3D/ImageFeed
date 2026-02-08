//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // Если запрос уже выполняется, не запускаем новый
        if task != nil { return }
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            let error = NetworkError.invalidRequest
            print("[ProfileService.fetchProfile]: \(error) - Не удалось создать request")
            completion(.failure(error))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let result):
                    let profile = Profile(
                        username: result.username,
                        name: "\(result.firstName) \(result.lastName ?? "")"
                            .trimmingCharacters(in: .whitespaces),
                        loginName: "@\(result.username)",
                        bio: result.bio
                    )
                    self.profile = profile
                    completion(.success(profile))
                    
                case .failure(let error):
                    self.logError(error)
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func logError(_ error: Error) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code):
                print("[ProfileService.fetchProfile]: NetworkError - код ошибки \(code)")
            case .decodingError(let decodingError):
                print("[ProfileService.fetchProfile]: Decoding error - \(decodingError)")
            default:
                print("[ProfileService.fetchProfile]: NetworkError - \(networkError)")
            }
        } else {
            print("[ProfileService.fetchProfile]: Unknown error - \(error.localizedDescription)")
        }
    }
}
