//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import Foundation

// MARK: - Models
struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String? // Сделаем опциональным для безопасности
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

// MARK: - Service
final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        // Отменяем текущую задачу перед созданием новой
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            // Безопасно возвращаем ошибку без принудительного приведения типов
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            // Переходим на главный поток для обработки результата и вызова completion
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profileResult):
                    // Собираем полное имя безопасно
                    let fullName = [profileResult.firstName, profileResult.lastName]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    let profile = Profile(
                        username: profileResult.username,
                        name: fullName,
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio
                    )
                    
                    self.profile = profile
                    completion(.success(profile))
                    
                case .failure(let error):
                    print("[ProfileService]: Ошибка запроса - \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func reset() {
        profile = nil
        task?.cancel()
        task = nil
    }
}
