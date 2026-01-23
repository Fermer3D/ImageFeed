//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 23.01.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
            didSet {
                guard isViewLoaded, let image else { return }
                configure(with: image)
            }
        }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    override func viewDidLoad() {
           super.viewDidLoad()

           scrollView.delegate = self
           scrollView.minimumZoomScale = 0.1
           scrollView.maximumZoomScale = 3.0

           if let image { configure(with: image) }
       }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func configure(with image: UIImage) {
            imageView.image = image

            // ВАЖНО: работаем с фреймами -> отключи влияние Auto Layout на imageView
            imageView.translatesAutoresizingMaskIntoConstraints = true

            view.layoutIfNeeded()

            imageView.frame = CGRect(origin: .zero, size: image.size)
            scrollView.contentSize = image.size

            rescaleAndCenterImageInScrollView()
        }

        private func rescaleAndCenterImageInScrollView() {
            view.layoutIfNeeded()

            let boundsSize = scrollView.bounds.size
            let imageSize = imageView.bounds.size

            guard imageSize.width > 0, imageSize.height > 0 else { return }

            let xScale = boundsSize.width / imageSize.width
            let yScale = boundsSize.height / imageSize.height
            let minScale = min(xScale, yScale)

            let scale = max(scrollView.minimumZoomScale,
                            min(scrollView.maximumZoomScale, minScale))

            scrollView.zoomScale = scale

            centerImage()
        }

        private func centerImage() {
            let boundsSize = scrollView.bounds.size
            let contentSize = scrollView.contentSize

            let horizontalInset = max(0, (boundsSize.width - contentSize.width) / 2)
            let verticalInset   = max(0, (boundsSize.height - contentSize.height) / 2)

            scrollView.contentInset = UIEdgeInsets(
                top: verticalInset,
                left: horizontalInset,
                bottom: verticalInset,
                right: horizontalInset
            )
        }
    }

    extension SingleImageViewController: UIScrollViewDelegate {
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage()
        }
    }
