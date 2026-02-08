//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private(set) var profile: Profile?
    
    private var imageView: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupImageView()
        
        if let token = storage.token  {
            switchToTabBarController()
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "Vector")
        
        imageView = UIImageView(image: imageSplashScreenLogo)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        
        guard let token = storage.token else { return }
        fetchProfile(token: token)
        
        switchToTabBarController()
    }
    
    private func fetchProfile(token: String) {
            UIBlockingProgressHUD.show()
            profileService.fetchProfile(token) { [weak self] result in
                UIBlockingProgressHUD.dismiss()

                guard let self = self else { return }

                switch result {
                case let .success(profile):
                   ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }

                   self.switchToTabBarController()
                case let .failure(error):
                    print(error)
                    break
                }
            }
        }
}
