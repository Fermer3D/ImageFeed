//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage()
    
    private var isAuthenticating = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        if isAuthenticating {
            return
        }

        if storage.token != nil {
            switchToTabBarController()
        } else {
            
            isAuthenticating = true
            performSegue(withIdentifier: "ShowAuthenticationScreen", sender: nil)
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            
            self.switchToTabBarController()
        }
    }
}
