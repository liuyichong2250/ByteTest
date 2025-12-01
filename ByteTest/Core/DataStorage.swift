import Foundation

final class DataStorage {
    static let shared = DataStorage()
    private init() {}

    private let StorageFileName = "videos.json"

    func saveVideos(_ videos: [VideoItem]) throws {
        let data = try JSONEncoder().encode(videos)
        let url = try storageUrl()
        try data.write(to: url, options: .atomic)
    }

    func loadVideos() -> [VideoItem] {
        do {
            let url = try storageUrl()
            let data = try Data(contentsOf: url)
            let items = try JSONDecoder().decode([VideoItem].self, from: data)
            return items
        } catch {
            return []
        }
    }

    private func storageUrl() throws -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(StorageFileName)
    }
}
