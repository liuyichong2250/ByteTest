import Foundation

struct RemoteVideoInfo: Decodable {
    let id: String
    let title: String
    let thumbnailUrl: String
    let duration: String
    let uploadTime: String
    let views: String
    let author: String
    let videoUrl: String
    let description: String
    let subscriber: String
    let isLive: Bool
}

final class VideoFactory {
    static func makeItems(from remote: [RemoteVideoInfo]) -> [VideoItem] {
        remote.enumerated().compactMap { index, info in
            guard let cover = URL(string: info.thumbnailUrl) else { return nil }
            let avatar = URL(string: "https://i.pravatar.cc/100?img=\(((index % 70) + 1))")!
            let play = URL(string: PlayUrl)!
            let viewsInt = parseViews(info.views)
            return VideoItem(
                id: info.id,
                coverUrl: cover,
                tag: .Live,
                title: info.title,
                avatarUrl: avatar,
                nickname: info.author,
                playUrl: play,
                viewsCount: viewsInt
            )
        }
    }

    private static func parseViews(_ s: String) -> Int {
        let digits = s.filter { $0.isNumber }
        return Int(digits) ?? Int.random(in: 12000...23000)
    }
}
