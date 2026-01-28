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
