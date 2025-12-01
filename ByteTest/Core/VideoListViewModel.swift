import Foundation
import Combine

@MainActor
final class VideoListViewModel: ObservableObject {
    @Published var items: [VideoItem] = []
    @Published var isLoading: Bool = false

    private let repository: VideoRepository

    init(repository: VideoRepository) {
        self.repository = repository
    }

    func load() {
        isLoading = true
        Task {
            let videos = await repository.fetchVideos()
            items = videos
            isLoading = false
        }
    }
}
