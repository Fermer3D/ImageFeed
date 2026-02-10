//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 08.02.2026.
//

import UIKit
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
        
        HTTPCookieStorage.shared.removeCookies(since: .distantPast)
        
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                dataStore.removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplash() {
        DispatchQueue.main.async {
            
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            
            guard let window = window else {
                
                if let fallbackWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                    self.setupRoot(for: fallbackWindow)
                }
                return
            }
            
            self.setupRoot(for: window)
        }
    }
    
    private func setupRoot(for window: UIWindow) {
        
        let splashViewController = SplashViewController()
        
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
        
        
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }
}
