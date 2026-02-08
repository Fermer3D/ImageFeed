//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("❌ [URLSession]: System Error - \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [URLSession]: Not an HTTP Response")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            let statusCode = httpResponse.statusCode
            print("🌐 [URLSession]: Status Code - \(statusCode)")
            
            
            if !(200..<300 ~= statusCode) {
                print("❌ [URLSession]: Server Error Status - \(statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            
            
            guard let data = data, !data.isEmpty else {
                print("❌ [URLSession]: Response data is empty")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
           
            fulfillCompletionOnTheMainThread(.success(data))
        }
        return task
    }
}
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученные данные: \(jsonString)")
                }
                
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("Ошибка декодирования: \(decodingError), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    } else {
                        print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
