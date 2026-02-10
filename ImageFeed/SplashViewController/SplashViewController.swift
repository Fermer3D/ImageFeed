//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    // Используем опционал и lazy для безопасной инициализации
    private var imageView: UIImageView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods
    private func setupImageView() {
        view.backgroundColor = .black // Устанавливаем фон, чтобы логотип был виден
        
        let splashLogo = UIImage(named: "Vector")
        let imageView = UIImageView(image: splashLogo)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        self.imageView = imageView
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // Безопасно извлекаем контроллер из Storyboard
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        // Безопасный поиск активного окна
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                // Загружаем аватарку сразу после получения профиля
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                
            case .failure(let error):
                print("[SplashViewController]: Error fetching profile - \(error)")
                // В случае ошибки можно показать алерт или вернуть на экран авторизации
                self.presentAuthViewController()
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // Сначала скрываем экран авторизации
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self,
                  let token = self.storage.token else { return }
            
            // Затем загружаем данные профиля
            self.fetchProfile(token: token)
        }
    }
}
