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
        cellImage.kf.cancelDownloadTask()
        cellImage.image = UIImage(named: "Stub")
    }
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "likeButtonOn" : "likeButtonOff"
        
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        
        likeButton.setImage(image, for: .normal)
    }
    
}

