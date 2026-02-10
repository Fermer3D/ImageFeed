//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import UIKit

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

import Foundation

final class ImagesListService {
    // MARK: - Public Properties
    private(set) var photos: [Photo] = []
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private var lastLoadedPage: Int?
    private let perPage = 10
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let urlSession = URLSession.shared
    
    // MARK: - Formatters
    private let isoFormatter = ISO8601DateFormatter()
    private let isoFormatterWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
    
    private init() { }
    
    // MARK: - Public Methods
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        likeTask?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.httpStatusCode(401)))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            guard let self = self else { return }
            defer { self.likeTask = nil }
            
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }
            
            DispatchQueue.main.async {
                // Безопасное обновление состояния лайка в локальном массиве
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let oldPhoto = self.photos[index]
                    let newPhoto = Photo(
                        id: oldPhoto.id,
                        size: oldPhoto.size,
                        createdAt: oldPhoto.createdAt,
                        welcomeDescription: oldPhoto.welcomeDescription,
                        thumbImageURL: oldPhoto.thumbImageURL,
                        largeImageURL: oldPhoto.largeImageURL,
                        isLiked: !oldPhoto.isLiked
                    )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            }
        }
        self.likeTask = task
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        // Защита от одновременных запросов
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = makePhotosRequestURL(page: nextPage) else {
            print("[ImagesListService]: Ошибка формирования URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            defer { self.task = nil }
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { self.mapToPhoto($0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                print("[ImagesListService] fetchPhotosNextPage error: \(error.localizedDescription)")
            }
        }
        
        self.task = newTask
        newTask.resume()
    }
    
    func reset() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
        likeTask?.cancel()
        likeTask = nil
    }
    
    // MARK: - Private Methods
    
    private func makePhotosRequestURL(page: Int) -> URL? {
        guard var components = URLComponents(string: "https://api.unsplash.com/photos") else { return nil }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        return components.url
    }
    
    private func mapToPhoto(_ result: PhotoResult) -> Photo {
        Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: result.createdAt.flatMap { parseDate($0) },
            welcomeDescription: result.description,
            thumbImageURL: result.urls.regular,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    private func parseDate(_ string: String) -> Date? {
        isoFormatterWithFractional.date(from: string) ?? isoFormatter.date(from: string)
    }
}

//    func reset() {
//        photos = []
//        lastLoadedPage = nil
//        task?.cancel()
//        task = nil
//        likeTask?.cancel()
//        likeTask = nil
//    }
//}
