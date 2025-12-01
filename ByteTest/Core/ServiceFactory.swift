import Foundation

final class ServiceFactory {
    static func makeVideoRepository() -> VideoRepository {
        VideoRepository(networkClient: NetworkClient.shared, storage: DataStorage.shared)
    }

    static func makeVideoListViewModel() -> VideoListViewModel {
        VideoListViewModel(repository: makeVideoRepository())
    }
}
