//
//  WebView.swift
//  Feader
//
//  Created by fiahfy on 2023/02/18.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var urlString: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }

        uiView.load(URLRequest(url: url))
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(urlString: "https://fiahfy.blogspot.com/2019/07/chrome-100.html")
    }
}
