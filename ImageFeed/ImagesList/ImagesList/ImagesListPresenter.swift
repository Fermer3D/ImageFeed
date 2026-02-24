//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 24.02.2026.
//
import UIKit
import Foundation

@MainActor // Добавляем изоляцию, так как протокол привязан к MainActor
final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // В протоколе указано { get set }, поэтому реализуем как обычную переменную.
    // Но обновлять её будем из данных сервиса.
    var photos: [Photo] = []
    
    func viewDidLoad() {
        setupNotificationObserver()
        // Синхронизируем текущие фото при загрузке
        photos = imagesListService.photos
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayRow(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        // Проверяем границы массива для безопасности
        guard photos.indices.contains(indexPath.row) else { return }
        
        let photo = photos[indexPath.row]
        
        // Показываем индикатор (опционально, если это не делает контроллер)
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
                // Обновляем локальный массив из сервиса
                self.photos = self.imagesListService.photos
                self.view?.reloadRow(at: indexPath)
            case .failure:
                // Тут можно вызвать показ алертов через view
                break
            }
        }
    }
    
    private func setupNotificationObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            
            let oldCount = self.photos.count
            let newPhotos = self.imagesListService.photos
            let newCount = newPhotos.count
            
            if newCount > oldCount {
                self.photos = newPhotos
                self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
            }
        }
    }
}
