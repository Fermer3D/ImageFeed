//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
      
    private init() { }

    func logout() {
        OAuth2TokenStorage.shared.token = nil

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()

        cleanCookies()

        switchToSplash()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplash() {
        DispatchQueue.main.async {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first
            else { return }

            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
    }
}
