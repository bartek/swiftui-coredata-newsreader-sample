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
    
    // Hard codes searching for anything to do with "apple"
    private final var urlBase = "https://newsapi.org/v2/everything"

    // Additional paramaters passed into newsapi
    // An API key would not normally be included in a code base but there's no risk in including this particular newsapi key here.
    let apiKey = "0411380452114d41b844618f26517140"
    let language = "en"

    // Default to search for `apple`
    var searchQuery = "apple"
    
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
        
        let urlString = "\(urlBase)?q=\(searchQuery)&apiKey=\(apiKey)&language=\(language)&page=\(nextPageToLoad)"
        let url = URL(string: urlString)!
        print("Calling \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: parseResponse)
        currentlyLoading = true
        task.resume()
    }
    
    func shouldLoadMoreArticles(_ article: Article? = nil) -> Bool {
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
    
    // Updates the searchQuery and clears local cache
    func updateSearchQuery(_ query: String) {
        self.reset()
        
        self.searchQuery = query
        self.loadMoreArticles()
    }
    
    // Reset persistent store and local cache
    func reset() {
        self.articleItems = []
        self.doneLoading = false
        self.nextPageToLoad = 1
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let moc = appDelegate.persistentContainer.viewContext
        
        do {
            try moc.execute(deleteRequest)
            try moc.save()
        } catch {
            print("Clearing went kaboom \(error.localizedDescription)")
        }
        
        moc.reset()
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
                article.setValue(articleData.url, forKeyPath: "url")
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
            
            guard let url = articleMap["url"] as? String else {
                continue
            }
            
            // Need to convert the publishedAt date as it's coming from a JSON string
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let publishedDate = dateFormatter.date(from: publishedAt)!
            
            articleItems.append(ArticleData(
                title: title,
                author: author,
                url: url,
                publishedAt: publishedDate
            ))
        }
        
        return articleItems
    }
}

class ArticleData: Identifiable {
    var title: String = ""
    var author: String = ""
    var publishedAt: Date?
    var url: String = ""
    var uuid: String = UUID().uuidString
    
    init(title: String, author: String, url: String, publishedAt: Date) {
        self.title = title
        self.author = author
        self.url = url
        self.publishedAt = publishedAt
    }
}
