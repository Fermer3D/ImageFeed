//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 28.01.2026.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
