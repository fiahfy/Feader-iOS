//
//  ContentView.swift
//  Feader
//
//  Created by fiahfy on 2023/02/18.
//

import SwiftUI

struct RSS: Codable {
    struct Feed: Codable {
        struct Entry: Codable {
            struct Link: Codable {
                let rel: String
                let href: String
            }

            let id: String
            let title: String
            let links: [Link]

            var permalink: String? {
                return links.filter { $0.rel == "alternate" }.first?.href
            }

            enum CodingKeys: String, CodingKey {
                case id
                case title
                case links = "link"
            }

            enum IdCodingKeys: String, CodingKey {
                case value = "$t"
            }

            enum TitleCodingKeys: String, CodingKey {
                case value = "$t"
            }

            init(from decoder: Decoder) throws {
                let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
                let idContainer = try rootContainer.nestedContainer(keyedBy: IdCodingKeys.self, forKey: .id)
                let titleContainer = try rootContainer.nestedContainer(keyedBy: TitleCodingKeys.self, forKey: .title)

                links = try rootContainer.decode([Link].self, forKey: .links)
                id = try idContainer.decode(String.self, forKey: .value)
                title = try titleContainer.decode(String.self, forKey: .value)
            }

            func encode(to encoder: Encoder) throws {
                var rootContainer = encoder.container(keyedBy: CodingKeys.self)
                var idContainer = rootContainer.nestedContainer(keyedBy: IdCodingKeys.self, forKey: .id)
                var titleContainer = rootContainer.nestedContainer(keyedBy: TitleCodingKeys.self, forKey: .title)

                try rootContainer.encode(links, forKey: .links)
                try idContainer.encode(id, forKey: .value)
                try titleContainer.encode(title, forKey: .value)
            }
        }

        let entries: [Entry]

        enum CodingKeys: String, CodingKey {
            case entries = "entry"
        }
    }

    let encoding: String
    let version: String
    let feed: Feed
}

struct Item: Identifiable {
    let id: String
    let urlString: String
}

struct ContentView: View {
    @State private var entries = [RSS.Feed.Entry]()
    @State private var isPresented = false
    @State private var item: Item?

    var body: some View {
        List(entries, id: \.id) { entry in
            Button {
                guard let permalink = entry.permalink else {
                    return
                }
                item = Item(id: entry.id, urlString: permalink)
            } label: {
                Text(entry.title)
            }
        }
        .listStyle(.plain)
        .sheet(item: $item) { item in
            WebView(urlString: item.urlString)
        }
        .refreshable {
            await load()
        }
        .onAppear {
            Task {
                await load()
            }
        }
    }

    private func load() async {
        guard let url = URL(string: "https://fiahfy.blogspot.com/feeds/posts/summary?alt=json") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let rss = try? JSONDecoder().decode(RSS.self, from: data) else {
                return
            }
            entries = rss.feed.entries
        } catch {
            return
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
