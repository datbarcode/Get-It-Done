//
//  CollectionViewCell.swift
//  GetItDone
//
//  Created by David Barko on 1/8/21.
//  Copyright © 2021 David Barko. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    

    static let identifier = "CollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "CollectionViewCell", bundle: nil)
    }
    public func configure(with title: Data) {
        let imgView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        imgView.layer.cornerRadius = 8.0
        imgView.clipsToBounds = true
        let img = UIImage(data: title)
        imgView.image = img
        self.contentView.addSubview(imgView)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Set appearance
       // cell.layer.cornerRadius = cell.frame.height / 8
       // cell = UITableViewCell.SelectionStyle.none
    }
}
