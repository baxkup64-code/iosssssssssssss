import SwiftUI
import WebKit

struct ProviderPlayerView: UIViewRepresentable {
    let trackURL: URL
    let source: TrackSource

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedURL: URL?
        switch source {
        case .spotify:
            let parts = trackURL.path.split(separator: "/").map(String.init)
            if let i = parts.firstIndex(of: "track"), parts.indices.contains(i + 1) {
                embedURL = URL(string: "https://open.spotify.com/embed/track/\(parts[i + 1])?theme=0")
            } else {
                embedURL = trackURL
            }
        case .soundcloud:
            var components = URLComponents(string: "https://w.soundcloud.com/player/")!
            components.queryItems = [
                URLQueryItem(name: "url", value: trackURL.absoluteString),
                URLQueryItem(name: "auto_play", value: "true"),
                URLQueryItem(name: "hide_related", value: "true"),
                URLQueryItem(name: "show_comments", value: "false"),
                URLQueryItem(name: "show_user", value: "true"),
                URLQueryItem(name: "show_reposts", value: "false"),
                URLQueryItem(name: "show_teaser", value: "false"),
                URLQueryItem(name: "visual", value: "false")
            ]
            embedURL = components.url
        case .local:
            embedURL = nil
        }

        guard let embedURL, webView.url != embedURL else { return }
        webView.load(URLRequest(url: embedURL, cachePolicy: .useProtocolCachePolicy))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url,
                  let host = url.host?.lowercased() else {
                decisionHandler(.allow)
                return
            }
            let allowed = host == "open.spotify.com" || host.hasSuffix(".spotify.com") ||
                          host == "soundcloud.com" || host.hasSuffix(".soundcloud.com") ||
                          host == "w.soundcloud.com"
            decisionHandler(allowed ? .allow : .cancel)
        }
    }
}
