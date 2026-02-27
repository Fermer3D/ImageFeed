//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 23.01.2026.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    // MARK: - Presenter
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - UI Elements
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let profileImage = UIImageView()
    
    
    private let exitButton = UIButton.systemButton(
        with: UIImage(named: "Exit") ?? UIImage(),
        target: nil,
        action: nil
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        
        setupProfileImage()
        setupNameLabel()
        setupUsernameLabel()
        setupDescriptionLabel()
        setupExitButton()
        setupAccessibilityIdentifiers()
        
        // MVP: Инициализация связи
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
        usernameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            profileImage.image = UIImage(systemName: "person.circle.fill")
            profileImage.tintColor = .gray
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.circle.fill"),
            options: [
                .processor(processor),
                .cacheOriginalImage,
                .transition(.fade(0.2))
            ]
        )
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.didConfirmLogout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Actions
    
    @objc func didTapLogoutButton() { // Метод вызывается тестами и кнопкой
        presenter?.didTapLogout()
    }
    
    // MARK: - Private Methods
    
    private func setupAccessibilityIdentifiers() {
        nameLabel.accessibilityIdentifier = "Name Lastname"
        usernameLabel.accessibilityIdentifier = "@username"
        exitButton.accessibilityIdentifier = "logout button"
    }
    
    // MARK: - UI Setup (Constraints)
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 35
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func setupNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupUsernameLabel() {
        view.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .systemFont(ofSize: 13)
        usernameLabel.textColor = .gray
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupExitButton() {
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.tintColor = .red
        exitButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
