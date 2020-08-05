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
    // FIXME: apiKey is not mine ?
    private final var urlBase = "https://newsapi.org/v2/everything?q=apple&apiKey=6ffeaceffa7949b68bf9d68b9f06fd33&language=en&page="
    
    // Necessary for managing loading state
    var nextPageToLoad = 1
    var doneLoading = false
    var currentlyLoading = false
    
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
        // If the Article is nil, we likely are loading from initial state
        if article == nil {
            return true
        }
        
        return false
    }
    
    func parseResponse(data: Data?, urlResponse: URLResponse?, error: Error?) {
        print("Parsing a response")
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
                // add to core data
                let article = NSManagedObject(entity: articleEntity, insertInto: moc)
                moc.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)

                article.setValue(articleData.title, forKeyPath: "title")
                article.setValue(articleData.author, forKeyPath: "author")
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
        
        var articleItems = [ArticleData]()
        
        for articleMap in articleMapList {
            guard let title = articleMap["title"] as? String else {
                continue
            }
            
            guard let author = articleMap["author"] as? String else {
                continue
            }
            
            articleItems.append(ArticleData(title: title, author: author))
        }
        
        return articleItems
    }
}

class ArticleData: Identifiable {
    var title: String = ""
    var author: String = ""
    
    init(title: String, author: String) {
        self.title = title
        self.author = author
    }
}
