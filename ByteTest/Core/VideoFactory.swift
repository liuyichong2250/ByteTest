import Foundation

struct RemoteImageInfo: Decodable {
    let id: String
    let author: String
    let download_url: String
}

final class VideoFactory {
    static func makeItems(from remote: [RemoteImageInfo]) -> [VideoItem] {
        remote.enumerated().map { index, info in
            let cover = URL(string: info.download_url) ?? URL(string: "https://picsum.photos/400/300")!
            let avatar = URL(string: "https://i.pravatar.cc/100?img=\(((index % 70) + 1))")!
            let play = URL(string: PlayUrl)!
            return VideoItem(
                id: info.id,
                coverUrl: cover,
                tag: .Live,
                title: "Look how beautiful this flamingo is, nature creature \(info.author)",
                avatarUrl: avatar,
                nickname: info.author,
                playUrl: play,
                viewsCount: Int.random(in: 12000...23000)
            )
        }
    }
}
