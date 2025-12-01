import SwiftUI
import AVKit
import UIKit

struct FullscreenPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let vc = AVPlayerViewController()
        vc.player = player
        vc.showsPlaybackControls = false
        vc.videoGravity = .resizeAspectFill
        return vc
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct PlayerSlider: UIViewRepresentable {
    @Binding var value: Float
    var range: ClosedRange<Float>
    @Binding var isDragging: Bool
    var onEditingChanged: (Bool) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UISlider {
        let s = UISlider(frame: .zero)
        s.minimumValue = range.lowerBound
        s.maximumValue = range.upperBound
        s.value = value
        s.minimumTrackTintColor = UIColor.white
        s.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.25)
        s.setThumbImage(hiddenThumb(), for: .normal)
        s.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        s.addTarget(context.coordinator, action: #selector(Coordinator.touchDown(_:)), for: .touchDown)
        s.addTarget(context.coordinator, action: #selector(Coordinator.touchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return s
    }

    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.minimumValue = range.lowerBound
        uiView.maximumValue = range.upperBound
        if uiView.value != value { uiView.value = value }
        uiView.setThumbImage(hiddenThumb(), for: .normal)
    }

    class Coordinator: NSObject {
        var parent: PlayerSlider
        init(_ parent: PlayerSlider) { self.parent = parent }
        @objc func valueChanged(_ sender: UISlider) { parent.value = sender.value }
        @objc func touchDown(_ sender: UISlider) { parent.isDragging = true; parent.onEditingChanged(true) }
        @objc func touchUp(_ sender: UISlider) { parent.isDragging = false; parent.onEditingChanged(false) }
    }

    private func visibleThumb() -> UIImage {
        let size = CGSize(width: 18, height: 18)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).fill()
        }
    }
    private func hiddenThumb() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.clear.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        }
    }
}

struct VideoPlayerView: View {
    let url: URL
    var title: String? = nil
    var nickname: String? = nil
    var avatarUrl: URL? = nil
    var viewsCount: Int? = nil
    var tagText: String? = nil

    @State private var player: AVPlayer = AVPlayer()
    @State private var isPlaying: Bool = true
    @State private var isMuted: Bool = false
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 13000
    @State private var currentTime: Double = 0
    @State private var totalTime: Double = 1
    @State private var timeObserverToken: Any?
    @State private var isSliderDragging: Bool = false

    var body: some View {
        ZStack {
            FullscreenPlayerView(player: player)
                .ignoresSafeArea()

            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    togglePlay()
                }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        isMuted.toggle()
                        player.isMuted = isMuted
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                            .padding(12)
                    }
                }
                Spacer()
            }

            VStack {
                Spacer()
                LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                    .frame(height: 220)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .bottom)

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 10) {
                        if let tagText {
                            Text(tagText)
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                        if let title {
                            Text(title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                        }
                        HStack(spacing: 8) {
                            if let avatarUrl {
                                AsyncImage(url: avatarUrl) { phase in
                                    if case .success(let image) = phase {
                                        image.resizable().scaledToFill()
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .frame(width: 26, height: 26)
                                .clipShape(Circle())
                            }
                            if let nickname {
                                Text(nickname)
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    Spacer()
                    VStack(spacing: 18) {
                        if let avatarUrl {
                            AsyncImage(url: avatarUrl) { phase in
                                if case .success(let image) = phase {
                                    image.resizable().scaledToFill()
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        }
                        Button {
                            isLiked.toggle()
                            likeCount += isLiked ? 1 : -1
                        } label: {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .white)
                                .font(.title2)
                        }
                        Text("\(viewsCount ?? likeCount)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Button {} label: {
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        Text("0")
                            .foregroundColor(.white)
                            .font(.caption)
                        Button {} label: {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                    }
                    .padding(.trailing, 8)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 28)
            }

            VStack {
                Spacer()
                VStack(spacing: 6) {
                    PlayerSlider(value: Binding(get: { Float(currentTime) }, set: { currentTime = Double($0) }), range: 0...Float(max(totalTime, 1)), isDragging: $isSliderDragging) { editing in
                        if !editing {
                            let t = CMTime(seconds: currentTime, preferredTimescale: 600)
                            player.seek(to: t, toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                    }
                    HStack {
                        Text(format(currentTime))
                            .foregroundColor(.white.opacity(0.9))
                            .font(.caption2)
                        Spacer()
                        Text(format(totalTime))
                            .foregroundColor(.white.opacity(0.7))
                            .font(.caption2)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            .ignoresSafeArea(edges: .bottom)

            if !isPlaying {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white)
                    .frame(width: 88, height: 88)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .onTapGesture { togglePlay() }
            }
        }
        .onAppear {
            likeCount = viewsCount ?? likeCount
            player.replaceCurrentItem(with: AVPlayerItem(url: url))
            player.play()
            player.isMuted = isMuted
            let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
                currentTime = CMTimeGetSeconds(time)
                if let d = player.currentItem?.duration.seconds, d.isFinite {
                    totalTime = d
                }
            }
        }
        .onDisappear {
            player.pause()
            if let token = timeObserverToken {
                player.removeTimeObserver(token)
                timeObserverToken = nil
            }
        }
    }

    private func format(_ seconds: Double) -> String {
        guard seconds.isFinite && !seconds.isNaN else { return "--:--" }
        let s = Int(seconds.rounded())
        let m = s / 60
        let r = s % 60
        return String(format: "%02d:%02d", m, r)
    }

    private func togglePlay() {
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
}
