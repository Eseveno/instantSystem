//
//  NewsTableViewCell.swift
//  instantSystem
//
//  Created by Erwan seveno on 16/01/2020.
//  Copyright © 2020 Erwan seveno. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var newsDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.newsView.layer.cornerRadius = 12
        self.newsView.clipsToBounds = true
        self.selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        newsTitle.text = ""
        newsImage.image = nil
        newsDate.text = ""
        
    }
}
