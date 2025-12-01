//
//  ContentView.swift
//  ByteTest
//
//  Moved to UI layer
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var viewModel = ServiceFactory.makeVideoListViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    let spacing: CGFloat = 12
                    let availableWidth = proxy.size.width - spacing * 2
                    let columnWidth = (availableWidth - spacing) / 2
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: spacing),
                        GridItem(.flexible(), spacing: spacing)
                    ], spacing: spacing) {
                        ForEach(viewModel.items) { item in
                            NavigationLink {
                                VideoPlayerView(url: item.playUrl, title: item.title, nickname: item.nickname, avatarUrl: item.avatarUrl, viewsCount: item.viewsCount, tagText: item.tag.rawValue)
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                VideoCardView(item: item, cardWidth: columnWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, spacing)
                    .padding(.top, spacing)
                }
            }
            .navigationTitle("LIVE • MLBB: Zetan")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.load()
        }
    }
}

#Preview {
    ContentView()
}
