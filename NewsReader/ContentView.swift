//
//  ContentView.swift
//  NewsReader
//
//  Created by Bartek Ciszkowski on 2020-08-03.
//  Copyright © 2020 Bartek Ciszkowski. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(entity: Article.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true)
    ]) var articles: FetchedResults<Article>
    
    // Manage the connection to the API and storing the results into Core Data
    var articleList = ArticleList()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List(articles) { article in
                    ArticleItemView(for: article)
                    .onAppear {
                        self.articleList.loadMoreArticles(article)
                    }
                }
            }.navigationBarItems(leading: Button("Clear") {
                print("Clearing Core Data")
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try self.moc.execute(deleteRequest)
                    try self.moc.save()
                } catch {
                    print("Clearing went kaboom \(error.localizedDescription)")
                }
            })
        }
    }
}

struct ArticleItemView: View {
    @State var showingArticle = false
    
    var article: Article
    
    var body: some View {
        
        let tap = TapGesture()
            .onEnded { _ in
                self.showingArticle = true
            }
        return VStack(alignment: .leading) {
            Text(article.title).font(.headline)
            Text(article.author).font(.subheadline)
            .gesture(tap)
        }
        .padding()
        .sheet(isPresented: $showingArticle) {
            ArticleDetailView(for: self.article.url)
        }
    }
    
    init(for article: Article) {
        self.article = article
    }
}

// For iOS 14 (Big Sur), we might want to use `Link` to load this in the defined browser!
struct ArticleDetailView: View {
    var articleUrl: String
    
    var body: some View {
        Webview(url: articleUrl)
    }
    
    init(for articleUrl: String) {
        self.articleUrl = articleUrl
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
#endif

