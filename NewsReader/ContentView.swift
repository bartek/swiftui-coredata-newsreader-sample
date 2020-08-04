//
//  ContentView.swift
//  NewsReader
//
//  Created by Bartek Ciszkowski on 2020-08-03.
//  Copyright © 2020 Bartek Ciszkowski. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc

    @FetchRequest(entity: Article.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Article.title, ascending: true)
    ]) var articles: FetchedResults<Article>
    
    // Manage the connection to the API and storing the results into Core Data
    var articleList = ArticleList()
    
    var body: some View {
        VStack(spacing: 0) {
            List(articles) { article in
                ArticlePreviewView(for: article)
            }
            
        }
    }
}

struct ArticlePreviewView: View {
    var article: Article
    
    var body: some View {
        VStack {
            Text(article.title)
        }
    }
    
    init(for article: Article) {
        self.article = article
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

