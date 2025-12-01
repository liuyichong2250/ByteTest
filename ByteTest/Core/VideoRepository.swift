import Foundation

final class VideoRepository {
    private let networkClient: NetworkClient
    private let storage: DataStorage

    init(networkClient: NetworkClient = NetworkClient.shared, storage: DataStorage = DataStorage.shared) {
        self.networkClient = networkClient
        self.storage = storage
    }

    func fetchVideos() async -> [VideoItem] {
        do {
            let url = URL(string: VideosFeedUrl)!
            let remote: [RemoteImageInfo] = try await networkClient.getDecodable([RemoteImageInfo].self, url: url)
            let items = VideoFactory.makeItems(from: remote)
            try storage.saveVideos(items)
            return items
        } catch {
            let cached = storage.loadVideos()
            if !cached.isEmpty { return cached }
            return []
        }
    }
}
