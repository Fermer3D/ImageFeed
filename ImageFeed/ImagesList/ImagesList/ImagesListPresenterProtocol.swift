//
//  Untitled.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//

import Foundation

@MainActor // Добавь это
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadRow(at indexPath: IndexPath)
}

@MainActor // И сюда
protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func willDisplayRow(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}
