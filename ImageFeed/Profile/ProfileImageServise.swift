//
//  ProfileImageServise.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    
    private let urlSession = URLSession.shared
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // Защита от гонки: если запрашиваем тот же аватар, что и сейчас — выходим
        if lastUsername == username { return }
        
        task?.cancel()
        lastUsername = username
        
        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NetworkError.invalidRequest // Или твой кастомный 401
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError - No Token")
            completion(.failure(error))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError - Invalid URL Request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let userResult):
                    let profileImageURL = userResult.profileImage.medium // Обычно используют medium или small
                    self.avatarURL = profileImageURL
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                    
                    self.task = nil
                case .failure(let error):
                    self.logError(error, username: username)
                    self.task = nil
                    self.lastUsername = nil
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func logError(_ error: Error, username: String) {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .httpStatusCode(let code):
                print("[ProfileImageService.fetchProfileImageURL]: NetworkError - код ошибки \(code) для \(username)")
            case .decodingError(let decodingError):
                print("[ProfileImageService.fetchProfileImageURL]: Decoding error - \(decodingError)")
            default:
                print("[ProfileImageService.fetchProfileImageURL]: NetworkError - \(networkError)")
            }
        } else {
            print("[ProfileImageService.fetchProfileImageURL]: Unknown error - \(error.localizedDescription)")
        }
    }
}
