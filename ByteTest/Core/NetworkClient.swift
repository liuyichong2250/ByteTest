import Foundation

final class NetworkClient {
    static let shared = NetworkClient()
    private init() {}

    func getDecodable<T: Decodable>(_ type: T.Type, url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
