//
//  NewsObject.swift
//  instantSystem
//
//  Created by Erwan seveno on 15/01/2020.
//  Copyright © 2020 Erwan seveno. All rights reserved.
//

import UIKit


protocol NewsObjectDelegate {
    func getNewsFinished()
}

class NewsObject: NSObject {
    
    var newsImageString: String?
    var newsDescription: String?
    var newsTitle: String?
    var newsLink: String?
    var newsDate: Date?
    var newsStockedImage : UIImage? // pour mettre en cache l'image
    
    // MARK: Parser
    
    // dictionaire des elements a récuperer dans l'xml
    let recordKey = "item"
    let dictionaryKeys = Set<String>(["title", "description", "link", "enclosure", "pubDate"])

    // MARK: Delegate
    
    var delegate: NewsObjectDelegate?
    
    // a few variables to hold the results as we parse the XML

    var results: [[String: String]]?         // the whole array of dictionaries
    var currentDictionary: [String: String]? // the current dictionary
    var currentValue: String?                // the current value for one of the keys in the dictionary
        
    // MARK: Initializer
    
    override init() {
        
    }
    
    // mapper
    init(aNew: [String:String]) {
        self.newsImageString = aNew["enclosure"]
        self.newsDescription = aNew["description"]
        self.newsTitle = aNew["title"]
        self.newsLink = aNew["link"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        self.newsDate = dateFormatter.date(from: aNew["pubDate"]!)
    }
    
    
    // MARK: datasource
    // recupère toutes les news a partir d'une url , parse l'xml, et crer un tableau de news envoyé dans la complétion
    public func getAllNewsWithUrl(url: String, completion: @escaping ([NewsObject]) -> ()) {
        
        var tabsOfNews = [NewsObject]()
        
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
               guard let data = data, error == nil else {
                      print(error ?? "Unknown error")
                      return
                  }
                
                let parser = XMLParser(data: data)
                parser.delegate = self
                if parser.parse() {
                    print(self.results ?? "No results")
                }
                
                for aNew in self.results! {
                    tabsOfNews.append(NewsObject(aNew: aNew))
                }
                
                completion(tabsOfNews)
            }
            task.resume()
        }
        return
    }
    
    
    // setImage met l'image de la news dans l'UIImage
    // si l'image n'est pas stocké, je la telecharge et je la stock
    
    public func setImage(imageView: UIImageView) {
        
        if let stockedImage = self.newsStockedImage {
            return imageView.image = stockedImage
        } else {
            if let imageString = self.newsImageString, let url = URL(string: imageString) {
              
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url)
                
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)
                        imageView.image = image
                        self.newsStockedImage = image
                    }
                }
            }
        }
    }
}

extension NewsObject: XMLParserDelegate {
    
    func parserDidStartDocument(_ parser: XMLParser) {
         self.results = []
    }

// est appelé en début de balise, si on elementname = recordKey ("Item") je vide le curentDictionary car il va me serir a remplire les infos pour chaque items
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName ==  self.recordKey {
             self.currentDictionary = [:]
        } else if dictionaryKeys.contains(elementName) && elementName != "enclosure" {
             self.currentValue = ""
        } else if dictionaryKeys.contains(elementName) && elementName == "enclosure"{
             self.currentDictionary?["enclosure"] = attributeDict["url"] ?? ""
        }
    }


// toutes les valeurs passe par ici du coup je les stock toutes
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue? += string
    }

// appelé en fin de balise si je crois </item> je concatène mes currentdictionnary au resultat final
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName ==  self.recordKey {
            if (self.results != nil) && (self.currentDictionary != nil) {
                self.results!.append(currentDictionary!)
                self.currentDictionary = nil
            }
        } else if dictionaryKeys.contains(elementName) && elementName != "enclosure" {
            self.currentDictionary?[elementName] = self.currentValue
            self.currentValue = nil
        } 
    }


    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)

         self.currentValue = nil
         self.currentDictionary = nil
         self.results = nil
    }
    
}
