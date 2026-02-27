//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import Foundation

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURL: Constants.defaultBaseURL ?? URL(string: "https://api.unsplash.com")!,
            authURLString: "https://unsplash.com/oauth/authorize"
        )
    }
}
