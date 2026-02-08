//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 27.01.2026.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "Vector")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // РАЗКОММЕНТИРУЙ для теста регистрации:
        // storage.token = nil
        
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        if let token = storage.token {
            print("[SplashVC]: Токен найден, загружаем профиль...")
            fetchProfile(token: token)
        } else {
            print("[SplashVC]: Токен не найден, открываем экран авторизации")
            presentAuthViewController()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Failed to instantiate AuthViewController")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        // Получаем активное окно через connectedScenes (современный способ)
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
                assertionFailure("Invalid window configuration")
                return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
           
        print("[SplashVC]: Выполняю подмену rootViewController на TabBar")
        window.rootViewController = tabBarController
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("[SplashVC]: Делегат получил сигнал об успешной авторизации")
        
        // Сначала скрываем контроллер авторизации
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if let token = self.storage.token {
                self.fetchProfile(token: token)
            } else {
                print("[SplashVC]: Ошибка - токен не сохранился после авторизации!")
            }
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    print("[SplashVC]: Профиль \(profile.username) загружен успешно")
                    
                    // Загружаем аватарку параллельно
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                    
                    // Прячем HUD и переключаем экран
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                    
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("[SplashVC]: Ошибка загрузки профиля: \(error)")
                    self.showErrorAlert()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
