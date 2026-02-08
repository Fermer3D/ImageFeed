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

final class ImagesListService {
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var lastLoadedPage: Int?
    private let perPage = 10
    
    private let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private let isoFormatterWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func parseDate(_ string: String) -> Date? {
        isoFormatterWithFractional.date(from: string) ?? isoFormatter.date(from: string)
    }
    
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private let urlSession = URLSession.shared
    
    static let shared = ImagesListService()
    
    private init() { }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        likeTask?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.httpStatusCode(401)))
            }
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = urlSession.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }
            defer {self.likeTask = nil}
            
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
                return
            }

            DispatchQueue.main.async {
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                   let photo = self.photos[index]
                   let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                    self.photos[index] = newPhoto
                }
                completion(.success(()))
            }
        }
        likeTask = task
        task.resume()
    }
    
    func fetchPhotosNextPage() {
        if task != nil { return }

        let nextPage = (lastLoadedPage ?? 0) + 1

                
        guard var components = URLComponents(string: "https://api.unsplash.com/photos") else { return }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = components.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")

        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }

            switch result {
            case .success(let photoResults):
                let newPhotos: [Photo] = photoResults.map { pr in
                    Photo(
                        id: pr.id,
                        size: CGSize(width: pr.width, height: pr.height),
                        createdAt: pr.createdAt.flatMap { self.parseDate($0) },
                        welcomeDescription: pr.description,
                        thumbImageURL: pr.urls.regular,
                        largeImageURL: pr.urls.full,
                        isLiked: pr.likedByUser
                    )
                }

                        
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }

            case .failure(let error):
                print("[ImagesListService] fetchPhotosNextPage error:", error)
            }
            self.task = nil
        }

        task = newTask
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
}
