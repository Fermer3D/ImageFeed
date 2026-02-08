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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем скролл
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadImage()
    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let img = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [img],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadImage() {
        guard let url = imageURL else { return }
        
        imageView.kf.indicatorType = .activity
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.imageView.frame.size = value.image.size
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Не надо", style: .cancel)
        let retry = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        alert.addAction(cancel)
        alert.addAction(retry)
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        // 1. Сначала принудительно обновляем лейаут, чтобы получить актуальные размеры scrollView
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // 2. Рассчитываем масштаб
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, min(hScale, vScale)))
        
        // 3. Устанавливаем масштаб и обновляем размеры контента
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // 4. Центрируем
        centerImage()
    }
    
    private func centerImage() {
        let visibleRectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        // Вычисляем свободное место. Если контент меньше экрана — делим остаток пополам.
        let x = max(0, (visibleRectSize.width - contentSize.width) / 2)
        let y = max(0, (visibleRectSize.height - contentSize.height) / 2)
        
        // Устанавливаем Inset-ы (поля), которые центрируют картинку
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Этот метод вызывается каждый раз, когда меняется масштаб (пальцами или программно)
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
