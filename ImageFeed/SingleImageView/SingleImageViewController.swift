//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 23.01.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!

    
    var imageURL: URL?
        
        private let activityIndicator: UIActivityIndicatorView = {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .white
            indicator.translatesAutoresizingMaskIntoConstraints = false
            return indicator
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupActivityIndicator()
            setupScrollView()
            loadImage()
        }
        
        private func setupScrollView() {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 1.25
        }

        private func setupActivityIndicator() {
            view.addSubview(activityIndicator)
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }

        private func loadImage() {
            guard let url = imageURL else { return }
            activityIndicator.startAnimating()
            
            imageView.kf.setImage(with: url) { [weak self] result in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let value):
                    self.imageView.frame.size = value.image.size
                    self.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure:
                    self.showError()
                }
            }
        }

        private func rescaleAndCenterImageInScrollView(image: UIImage) {
            view.layoutIfNeeded()
            
            let visibleRectSize = scrollView.bounds.size
            let imageSize = image.size
            
            let hScale = visibleRectSize.width / imageSize.width
            let vScale = visibleRectSize.height / imageSize.height
            
            let scale = min(hScale, vScale)
            
            scrollView.minimumZoomScale = scale
            scrollView.setZoomScale(scale, animated: false)
            
            scrollView.layoutIfNeeded()
            centerImage()
        }

        private func centerImage() {
            let visibleRectSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize
            
            let x = (visibleRectSize.width > contentSize.width) ? (visibleRectSize.width - contentSize.width) / 2 : 0
            let y = (visibleRectSize.height > contentSize.height) ? (visibleRectSize.height - contentSize.height) / 2 : 0
            
            scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
        }

        private func showError() {
            let alert = UIAlertController(title: "Ошибка", message: "Не удалось загрузить фото", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in self?.loadImage() })
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
            present(alert, animated: true)
        }

        @IBAction private func didTapBackButton(_ sender: Any) {
            dismiss(animated: true, completion: nil)
        }

        // ТОТ САМЫЙ МЕТОД, КОТОРОГО НЕ ХВАТАЛО
        @IBAction private func didTapShareButton(_ sender: UIButton) {
            guard let image = imageView.image else { return }
            let share = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            present(share, animated: true, completion: nil)
        }
    }

    extension SingleImageViewController: UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage()
        }
    }
