//
//  MainTableViewController.swift
//  instantSystem
//
//  Created by Erwan seveno on 15/01/2020.
//  Copyright © 2020 Erwan seveno. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    @IBOutlet var mainTableview: UITableView!
    
    var tableRefreshControl = UIRefreshControl()
    var tabOfNews: [NewsObject?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainTableview.delegate = self
        mainTableview.dataSource = self
        
        self.setupUI()
        self.getNews()
    }

    // MARK: - Table view data source
    // s'il n'y a pas de news retourne 0 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tabOfNews = self.tabOfNews {
            return tabOfNews.count
        } else {
            return 0
        }
    }

    // la taille des cellules est fixe , c'est plus homogène pour la tableview (esthetique)
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell

        
        cell.newsTitle.text = self.tabOfNews?[indexPath.row]?.newsTitle
        self.tabOfNews?[indexPath.row]?.setImage(imageView: cell.newsImage)
        
        if let news = self.tabOfNews?[indexPath.row], let date = news.newsDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy HH:mm"
            cell.newsDate.text = formatter.string(from: date)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DetailNewsSegue", sender: self.tableView.cellForRow(at: indexPath))
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailNewsSegue" {
            // recupere l'indexpath de la cellule selectioné grace au sender
            if let cell = sender as? NewsTableViewCell, let indexPath = mainTableview.indexPath(for: cell) {
                if let newsDetailViewController = segue.destination as? NewsViewController, let tabOfNews = self.tabOfNews {
                    newsDetailViewController.news = tabOfNews[indexPath.row]
                }
            }
        }
    }
    
    // MARK: method
    
    // ajoute le pull to refresh avec un layer en z -1 car la subview passais au premier plan devant les cellules.
    private func setupUI() {
        tableRefreshControl.attributedTitle = NSAttributedString(string: "Tirer pour rafraîchir")
        tableRefreshControl.addTarget(self, action: #selector(refreshTable(sender:)), for: UIControl.Event.valueChanged)
        tableRefreshControl.layer.zPosition = -1
        self.mainTableview.addSubview(tableRefreshControl)
    }
    
    
    // recupère les news et les refresh la tableview
    private func getNews() {
        NewsObject().getAllNewsWithUrl(url: "https://www.lemonde.fr/rss/une.xml", completion: { (success) -> Void in
            self.tabOfNews = []
            self.tabOfNews = success
            
            DispatchQueue.main.async {
                self.tableRefreshControl.endRefreshing()
                self.mainTableview.reloadData()
            }
        })
    }
    
    // appelé lors du pull to refresh
    @objc func refreshTable(sender:AnyObject) {
       getNews()
    }
}
