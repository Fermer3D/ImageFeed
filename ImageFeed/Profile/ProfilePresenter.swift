//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import Foundation
import UIKit

@MainActor
final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    // Делаем сервисы внедряемыми, чтобы избежать SIGABRT в тестах
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let logoutService: ProfileLogoutService

    init(
        profileService: ProfileService = .shared,
        profileImageService: ProfileImageService = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        // Безопасно обновляем данные профиля
        if let profile = profileService.profile {
            view?.updateProfileDetails(
                name: profile.name,
                login: profile.loginName,
                bio: profile.bio ?? ""
            )
        }
        updateAvatar()
    }
    
    func didTapLogout() {
        // Просто уведомляем View. Здесь не должно быть логики UIKit!
        view?.showLogoutAlert()
    }
    
    func didConfirmLogout() {
        logoutService.logout()
    }
    
    private func updateAvatar() {
        if let url = profileImageService.avatarURL {
            view?.updateAvatar(urlString: url)
        }
    }
}
