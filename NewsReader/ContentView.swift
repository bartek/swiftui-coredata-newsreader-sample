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

    @FetchRequest(
        entity: Article.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Article.publishedAt, ascending: true)
        ],
        predicate: NSPredicate(format: "hidden == %@", false)
    ) var articles: FetchedResults<Article>
    
    // Manage the connection to the API and storing the results into Core Data
    var articleList = ArticleList()
    
    @State private var searchString: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    
                    TextField("", text: $searchString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Update the search query
                        self.articleList.updateSearchQuery(self.searchString)
                    }) {
                        Text("Search")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        
                    }
                }.padding(20)
                
                    
                List {
                    ForEach(articles, id: \.self) { article in
                        NavigationLink(destination: ArticleDetailView(for: article.url)) {
                            ArticleItemView(for: article)
                            .onAppear {
                                self.articleList.loadMoreArticles(article)
                            }
                        }
                    }.onDelete(perform: delete)
                }
            }.navigationBarItems(leading: Button("Clear Data") {
                self.articleList.reset()
            })
        }
    }

    // For this naive implementation in this app, the data is retained in Core Data with an updated status.
    // This ensures that it does not get re-added when newsapi is called again.
    // The purpose of this code was to understand how to update a fetched result.
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let article = articles[index]
            article.setValue(true, forKey: "hidden")
        }
        
        try? moc.save()
    }
}

struct ArticleItemView: View {
    var article: Article
    
    var body: some View {
        
        return VStack(alignment: .leading) {
            Text(article.title).font(.headline)
            Text(article.author).font(.subheadline)
        }
        .padding()
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

