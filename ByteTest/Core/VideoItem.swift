import Foundation

enum VideoTag: String, Codable {
    case Live
}

struct VideoItem: Identifiable, Codable {
    let id: String
    let coverUrl: URL
    let tag: VideoTag
    let title: String
    let avatarUrl: URL
    let nickname: String
    let playUrl: URL
    let viewsCount: Int
}
