import SwiftUI
import WebKit

enum MusicProvider: String, CaseIterable, Identifiable {
    case spotify = "Spotify"
    case soundcloud = "SoundCloud"

    var id: String { rawValue }
}

struct ProviderSearchWebView: UIViewRepresentable {
    let provider: MusicProvider
    let query: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.alwaysBounceVertical = true
        webView.backgroundColor = .clear
        webView.isOpaque = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let url = URL(string: trimmed), let host = url.host?.lowercased(),
           host == "open.spotify.com" || host.hasSuffix(".spotify.com") ||
           host == "soundcloud.com" || host.hasSuffix(".soundcloud.com") {
            load(url: url, in: webView)
            return
        }

        var components: URLComponents?
        switch provider {
        case .spotify:
            components = URLComponents(string: "https://open.spotify.com/search/")
            components?.path += trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? trimmed
        case .soundcloud:
            components = URLComponents(string: "https://soundcloud.com/search")
            components?.queryItems = [URLQueryItem(name: "q", value: trimmed)]
        }

        guard let url = components?.url else { return }
        load(url: url, in: webView)
    }

    private func load(url: URL, in webView: WKWebView) {
        guard webView.url != url else { return }
        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url,
                  let host = url.host?.lowercased() else {
                decisionHandler(.allow)
                return
            }

            let allowed = host == "open.spotify.com" || host.hasSuffix(".spotify.com") ||
                          host == "spotify.com" ||
                          host == "soundcloud.com" || host.hasSuffix(".soundcloud.com") ||
                          host == "w.soundcloud.com"
            decisionHandler(allowed ? .allow : .cancel)
        }
    }
}
