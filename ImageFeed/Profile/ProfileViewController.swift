//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 23.01.2026.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let descriptionLabel = UILabel()
    let profileImage = UIImageView()
    let exitButton = UIButton.systemButton(
                with: UIImage(named: "Exit")!,
                target: ProfileViewController.self,
                action: #selector(Self.didTapExitButton)
    )
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "ypBlack")
        
        setupProfileImage()
        setupNameLabel()
        setupExitButton()
        setupUsernameLabel()
        setupDescriptionLabel()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
        }
        updateAvatar()
        
        guard let token = OAuth2TokenStorage.shared.token else { return }
        ProfileService.shared.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                self.updateProfileDetails(profile: profile)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        print("imageURL: \(url)")
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                case .failure(let error):
                    print(error)
                }
            }

    }
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        usernameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }

    
    @objc
    private func didTapExitButton(_ sender: Any) {
    }
    
    private func setupNameLabel() {
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8)
            ])
    }
    
    private func setupUsernameLabel() {
        view.addSubview(usernameLabel)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        usernameLabel.textColor = .gray
        usernameLabel.font = .systemFont(ofSize: 13)
        
        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupDescriptionLabel() {
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = .systemFont(ofSize: 13)
        
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        //profileImage.image = UIImage(named: "profilePhoto")
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }
    
    private func setupExitButton() {
        view.addSubview(exitButton)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.tintColor = .red
        
        NSLayoutConstraint.activate([
        exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
        exitButton.widthAnchor.constraint(equalToConstant: 44),
        exitButton.heightAnchor.constraint(equalToConstant: 44),
        exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
