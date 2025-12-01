import SwiftUI

struct VideoCardView: View {
    let item: VideoItem
    let cardWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: item.coverUrl) { phase in
                Group {
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.gray.opacity(0.2)
                    }
                }
            }
            .frame(width: cardWidth, height: cardWidth * 4/5)
            .clipped()
            .overlay(alignment: .topLeading) {
                Text(item.tag.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding(8)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text("\(item.viewsCount)")
                        .foregroundColor(.white)
                        .font(.caption)
                }
                .padding(8)
                .background(Color.black.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(8)
            }

            Text(item.title)
                .font(.subheadline)
                .lineLimit(2)

            HStack(spacing: 8) {
                AsyncImage(url: item.avatarUrl) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())

                Text(item.nickname)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: cardWidth, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}
