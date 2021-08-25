//
//  ImageCollectionViewCell.swift
//  PhotoGrid
//
//  Created by Astha Ameta on 8/19/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var gridImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

//    func configure(url: String) -> UIImage {
//       // let image: UIImage = gridImageView.load(urlString: url)
//        
//        contentView.layer.cornerRadius = 4.0
//        contentView.layer.borderWidth = 1.0
//        contentView.layer.borderColor = UIColor.clear.cgColor
//        contentView.layer.masksToBounds = false
//        layer.shadowColor = UIColor.gray.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 0)
//        layer.shadowRadius = 4.0
//        layer.shadowOpacity = 1.0
//        layer.masksToBounds = false
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
//        
//        return image
//    }
}
