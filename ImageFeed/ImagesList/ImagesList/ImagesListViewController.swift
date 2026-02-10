//
//  ViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 16.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
        private var photos: [Photo] = []
        private let imagesListService = ImagesListService.shared
        private var observer: NSObjectProtocol?
        
        private lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            return formatter
        }()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setupTableView()
            setupNotificationObserver()
            
            imagesListService.fetchPhotosNextPage()
        }
        
        deinit {
            if let observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        // MARK: - Overrides
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath,
                    photos.indices.contains(indexPath.row)
                else {
                    assertionFailure("Invalid segue destination or index")
                    return
                }
                
                let photo = photos[indexPath.row]
                if let url = URL(string: photo.largeImageURL) {
                    viewController.imageURL = url
                }
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
        
        // MARK: - Private Methods
        private func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        
        private func setupNotificationObserver() {
            observer = NotificationCenter.default.addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateTableViewAnimated()
            }
        }
        
        private func updateTableViewAnimated() {
            let oldCount = photos.count
            let newPhotos = imagesListService.photos
            let newCount = newPhotos.count
            
            guard newCount > oldCount else { return }
            
            photos = newPhotos
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    // MARK: - UITableViewDataSource
    extension ImagesListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photos.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ImagesListCell.reuseIdentifier,
                for: indexPath
            )
            
            guard let imageListCell = cell as? ImagesListCell else {
                return UITableViewCell()
            }
            
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
    }

    // MARK: - Cell Configuration
    extension ImagesListViewController {
        private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
            guard photos.indices.contains(indexPath.row) else { return }
            let photo = photos[indexPath.row]
            
            cell.delegate = self
            
            // Гарантируем правильное состояние лайка (решает проблему "исчезновения")
            cell.setIsLiked(photo.isLiked)
            
            // Установка даты
            if let createdAt = photo.createdAt {
                cell.dateLabel.text = dateFormatter.string(from: createdAt)
            } else {
                cell.dateLabel.text = ""
            }
            
            // Загрузка изображения
            let placeholder = UIImage(named: "Stub")
            cell.cellImage.kf.indicatorType = .activity
            
            if let url = URL(string: photo.thumbImageURL) {
                cell.cellImage.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [.cacheOriginalImage]
                )
            } else {
                cell.cellImage.image = placeholder
            }
        }
    }

    // MARK: - UITableViewDelegate
    extension ImagesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row == photos.count - 1 {
                imagesListService.fetchPhotosNextPage()
            }
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard photos.indices.contains(indexPath.row) else { return 0 }
            let photo = photos[indexPath.row]
            
            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            
            let imageWidth = photo.size.width
            let imageHeight = photo.size.height
            
            guard imageWidth > 0 else { return 0 }
            
            let scale = imageViewWidth / imageWidth
            return imageHeight * scale + imageInsets.top + imageInsets.bottom
        }
    }

    // MARK: - ImagesListCellDelegate
    extension ImagesListViewController: ImagesListCellDelegate {
        func imageListCellDidTapLike(_ cell: ImagesListCell) {
            guard let indexPath = tableView.indexPath(for: cell),
                  photos.indices.contains(indexPath.row) else { return }
            
            let photo = photos[indexPath.row]
            
            UIBlockingProgressHUD.show()
            
            imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    if self.photos.indices.contains(indexPath.row) {
                        cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    }
                    UIBlockingProgressHUD.dismiss()
                    
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("[imageListCellDidTapLike] Error: \(error)")
                    self.showLikeErrorAlert()
                }
            }
        }
        
        private func showLikeErrorAlert() {
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось изменить лайк. Попробуйте ещё раз.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            present(alert, animated: true)
        }
    }

