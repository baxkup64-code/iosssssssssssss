import Foundation

/// Provider resolver that intentionally uses no Spotify/SoundCloud API keys.
///
/// Normal text searches are handled by the provider's own web search pages
/// inside the app (see ProviderSearchWebView). Official Spotify/SoundCloud
/// track URLs are rendered with their provider player. No short preview URLs
/// are created by this app.
final class MusicAPIService {
    static let shared = MusicAPIService()

    func search(query: String) async -> SearchResults {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return SearchResults() }

        guard let url = URL(string: trimmed),
              let host = url.host?.lowercased(),
              let track = providerTrack(from: url, host: host) else {
            // Text queries are handled by the provider web search view.
            // This resolver only turns pasted provider URLs into Track models.
            return SearchResults()
        }

        return SearchResults(tracks: [track])
    }

    private func providerTrack(from url: URL, host: String) -> Track? {
        if host == "open.spotify.com" || host.hasSuffix(".spotify.com") {
            let parts = url.path.split(separator: "/").map(String.init)
            guard let index = parts.firstIndex(of: "track"), parts.indices.contains(index + 1) else {
                return nil
            }
            let id = parts[index + 1]
            guard !id.isEmpty else { return nil }
            return Track(
                id: "spotify-\(id)",
                title: "Spotify Track",
                artistName: "Spotify",
                albumName: "",
                artworkURL: nil,
                streamURL: nil,
                sourceURL: url,
                duration: 0,
                source: .spotify
            )
        }

        if host == "soundcloud.com" || host.hasSuffix(".soundcloud.com") {
            let parts = url.path.split(separator: "/").map(String.init)
            guard parts.count >= 2 else { return nil }
            let title = parts.dropFirst().joined(separator: " / ")
            return Track(
                id: "soundcloud-\(url.absoluteString)",
                title: title.isEmpty ? "SoundCloud Track" : title,
                artistName: parts.first ?? "SoundCloud",
                albumName: "",
                artworkURL: nil,
                streamURL: nil,
                sourceURL: url,
                duration: 0,
                source: .soundcloud
            )
        }

        return nil
    }
}
