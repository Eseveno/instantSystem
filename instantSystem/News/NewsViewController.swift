//
//  NewsViewController.swift
//  instantSystem
//
//  Created by Erwan seveno on 16/01/2020.
//  Copyright © 2020 Erwan seveno. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var newsDateLabel: UILabel!
    
    var news : NewsObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        
        self.newsTitleLabel.text = self.news.newsTitle
        self.newsDescriptionLabel.text = self.news.newsDescription
        self.news.setImage(imageView: self.newsImageView)
        
        if let date = self.news.newsDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            self.newsDateLabel.text = formatter.string(from: date)
        }

    }
    
    @IBAction func goToArticlePushed(_ sender: Any) {
        if let link = self.news.newsLink, let url = URL(string: link),
                UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
        }
    }
}
