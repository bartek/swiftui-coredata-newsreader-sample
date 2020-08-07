//
//  WebView.swift
//  NewsReader
//
//  Created by Bartek Ciszkowski on 2020-08-06.
//  Copyright © 2020 Bartek Ciszkowski. All rights reserved.
//

import Foundation
import WebKit
import SwiftUI

struct Webview: UIViewRepresentable {
    var url: String
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeUIView(context: Context) -> some WKWebView {
        guard let url = URL(string: self.url) else {
            // Simply return a blank page for simplicity
            return WKWebView()
        }
        
        let request = URLRequest(url: url)
        
        let wkWebView = WKWebView()
        wkWebView.load(request)
        return wkWebView
    }
}
