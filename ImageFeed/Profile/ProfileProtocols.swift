//
//  ProfileProtocols.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import Foundation

@MainActor
protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(urlString: String?)
    func showLogoutAlert()
}

@MainActor
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}
