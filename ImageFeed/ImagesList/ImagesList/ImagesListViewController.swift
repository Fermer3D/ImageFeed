//
//  ViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 16.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
        var presenter: ImagesListPresenterProtocol?
        
        private let showSingleImageSegueIdentifier = "ShowSingleImage"
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
            
            // Если презентер не был внедрен извне (например, в тестах), создаем его
            if presenter == nil {
                let presenter = ImagesListPresenter()
                self.presenter = presenter
                presenter.view = self
            }
            
            presenter?.viewDidLoad()
        }
        
        // MARK: - ImagesListViewControllerProtocol
        func updateTableViewAnimated(oldCount: Int, newCount: Int) {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
        
        func reloadRow(at indexPath: IndexPath) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        // MARK: - Private Methods
        private func setupTableView() {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath,
                    let photos = presenter?.photos,
                    photos.indices.contains(indexPath.row)
                else { return }
                
                let photo = photos[indexPath.row]
                if let url = URL(string: photo.largeImageURL) {
                    viewController.imageURL = url
                }
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }

    // MARK: - UITableViewDataSource
    extension ImagesListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return presenter?.photos.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
            guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
            configCell(for: imageListCell, with: indexPath)
            return imageListCell
        }
        
        private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
            guard let photo = presenter?.photos[indexPath.row] else { return }
            cell.delegate = self
            cell.setIsLiked(photo.isLiked)
            
            if let createdAt = photo.createdAt {
                cell.dateLabel.text = dateFormatter.string(from: createdAt)
            } else {
                cell.dateLabel.text = ""
            }
            
            cell.cellImage.kf.indicatorType = .activity
            let placeholder = UIImage(named: "Stub")
            if let url = URL(string: photo.thumbImageURL) {
                cell.cellImage.kf.setImage(with: url, placeholder: placeholder)
            }
        }
    }

    // MARK: - UITableViewDelegate
    extension ImagesListViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            presenter?.willDisplayRow(at: indexPath)
        }
    }

    // MARK: - ImagesListCellDelegate
    extension ImagesListViewController: ImagesListCellDelegate {
        func imageListCellDidTapLike(_ cell: ImagesListCell) {
            guard let indexPath = tableView.indexPath(for: cell) else { return }
            presenter?.didTapLike(at: indexPath)
        }
    }
