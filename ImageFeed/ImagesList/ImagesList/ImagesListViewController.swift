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

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    // когда показываем последнюю строку - грузим следующую страницу
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right

        let imageWidth = photo.size.width
        let imageHeight = photo.size.height

        guard imageWidth > 0 else { return 0 }

        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        
        let photo = photos[indexPath.row]

        // Дата
        imageListCell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""

        // Лайк
        let likeImage = photo.isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        imageListCell.likeButton.setImage(likeImage, for: .normal)

        // Плейсхолдер
        let placeholder = UIImage(named: "Stub")

        // Индикатор загрузки в imageView
        imageListCell.cellImage.kf.indicatorType = .activity

        if let url = URL(string: photo.thumbImageURL) {
            imageListCell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.cacheOriginalImage]
            )
        } else {
            imageListCell.cellImage.image = placeholder
        }

        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
                case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                
                let alert = UIAlertController(
                    title: "Ошибка",
                    message: "Не удалось изменить лайк. Попробуйте ещё раз.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "ОК", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}

