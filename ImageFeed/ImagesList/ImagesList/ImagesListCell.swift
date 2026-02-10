//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Данил Третьяченко on 21.01.2026.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask() // Отменяем загрузку
        cellImage.image = nil             // Очищаем фото
        likeButton.setImage(nil, for: .normal) // Очищаем старый лайк перед новой настройкой
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "LikeButtonOn" : "LikeButtonOff"
        
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        
        likeButton.setImage(image, for: .normal)
    }
    
}

