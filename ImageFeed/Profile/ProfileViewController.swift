//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 23.01.2026.
//

import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    
    // UI элементы (упрощено для краткости)
    private let nameLabel = UILabel()
    private let profileImage = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Инъекция презентера
        if presenter == nil {
            let presenter = ProfilePresenter()
            self.presenter = presenter
            presenter.view = self
        }
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - ProfileViewControllerProtocol
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
    }
    
    func updateAvatar(urlString: String?) {
        // Логика Kingfisher здесь
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Выход", message: "Уверены?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc func didTapLogoutButton() {
        presenter?.didTapLogout()
    }
}
