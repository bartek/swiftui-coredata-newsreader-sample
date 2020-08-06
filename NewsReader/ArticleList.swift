//
//  ArticleList.swift
//  NewsReader
//
//  Created by Bartek Ciszkowski on 2020-08-03.
//  Copyright © 2020 Bartek Ciszkowski. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

class ArticleList {
    // Representation of parsed article data
    typealias Element = ArticleData
    
    fileprivate var appDelegate: AppDelegate = {
        UIApplication.shared.delegate as! AppDelegate
    }()
        
    /*let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()*/
    
    // Hard codes searching for anything to do with "apple"
    private final var urlBase = "https://newsapi.org/v2/everything?q=apple&apiKey=0411380452114d41b844618f26517140&language=en&page="
    
    // Necessary for managing loading state
    var nextPageToLoad = 1
    var doneLoading = false
    var currentlyLoading = false
    
    // Articles fetched from the API are stored in memory for easy iteration and we don't worry about losing them on app close.
    @Published var articleItems = [ArticleData]()
    
    init() {
        loadMoreArticles()
    }
    
    func loadMoreArticles(_ article: Article? = nil) {
        if !shouldLoadMoreArticles(article) {
            return
        }
        
        let urlString = "\(urlBase)\(nextPageToLoad)"
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: parseResponse)
        currentlyLoading = true
        task.resume()
    }
    
    func shouldLoadMoreArticles(_ article: Article? = nil) -> Bool {
        
        // If we're done loading (based on our arbitrary limit), don't load more
        if doneLoading || currentlyLoading {
            return false
        }
        
        // If the Article is nil, we likely are loading from initial state
        if article == nil {
            return true
        }
        
        // If the article id (from onAppear) matches what's in memory, we're near end of list.
        for i in (articleItems.count-4) ... (articleItems.count-1) {
            if i >= 0 && articleItems[i].uuid == articleItems[i].uuid {
                return true
            }
            
        }
        
        return false
    }
    
    func parseResponse(data: Data?, urlResponse: URLResponse?, error: Error?) {
        guard error == nil else {
            print("\(error!)")
            DispatchQueue.main.async {
                self.currentlyLoading = false
            }
            return
        }
        
        guard let content = data else {
            print("No data!")
            DispatchQueue.main.async {
                self.currentlyLoading = false
            }
            return
        }
        
        let articles = getArticlesFromJson(content: content)
        
        let moc = appDelegate.persistentContainer.viewContext
        let articleEntity = NSEntityDescription.entity(forEntityName: "Article", in: moc)!
        
        
        DispatchQueue.main.async {
            for articleData in articles {
                // Save to persistent store
                let article = NSManagedObject(entity: articleEntity, insertInto: moc)
                article.setValue(articleData.title, forKeyPath: "title")
                article.setValue(articleData.author, forKeyPath: "author")
                article.setValue(articleData.publishedAt, forKeyPath: "publishedAt")
            }
            
            do {
                try moc.save()
            } catch {
                print("Whoops! \(error.localizedDescription)")
            }
            self.nextPageToLoad += 1
            self.doneLoading = (articles.count == 0)
            self.currentlyLoading = false
        }
    }
    
    func getArticlesFromJson(content: Data) -> [ArticleData] {
        let jsonObject = try! JSONSerialization.jsonObject(with: content)
        
        // Bad result
        guard let resultMap = jsonObject as? [String: Any] else {
            return []
        }
        
        // Try to get the articles
        guard let articleMapList = resultMap["articles"] as? [[String: Any]] else {
            return []
        }
                
        for articleMap in articleMapList {
            guard let title = articleMap["title"] as? String else {
                continue
            }
            
            guard let author = articleMap["author"] as? String else {
                continue
            }
            
            guard let publishedAt = articleMap["publishedAt"] as? String else {
                continue
            }
            
            // Need to convert the publishedAt date as it's coming from a JSON string
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            
            let publishedDate = dateFormatter.date(from: publishedAt)!
            articleItems.append(ArticleData(title: title, author: author, publishedAt: publishedDate))
        }
        
        return articleItems
    }
}

class ArticleData: Identifiable {
    var title: String = ""
    var author: String = ""
    var publishedAt: Date?
    var uuid: String = UUID().uuidString
    
    init(title: String, author: String, publishedAt: Date) {
        self.title = title
        self.author = author
        self.publishedAt = publishedAt
    }
}
