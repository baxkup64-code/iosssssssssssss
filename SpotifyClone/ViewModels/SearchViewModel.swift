import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results = SearchResults()
    @Published var isSearching = false
    @Published var provider: MusicProvider = .spotify

    private let api = MusicAPIService.shared
    private var searchTask: Task<Void, Never>?

    enum Filter: String, CaseIterable, Identifiable {
        case all = "Alles"
        case songs = "Songs"
        case artists = "Künstler"
        case albums = "Alben"
        case playlists = "Playlists"
        var id: String { rawValue }
    }

    @Published var activeFilter: Filter = .all

    func searchNow() {
        searchTask?.cancel()
        let currentQuery = query
        searchTask = Task { [weak self] in
            guard let self else { return }
            let trimmed = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                results = SearchResults()
                isSearching = false
                return
            }

            isSearching = true
            let searchResults = await api.search(query: trimmed)
            guard !Task.isCancelled else { return }
            results = searchResults
            isSearching = false
        }
    }

    deinit {
        searchTask?.cancel()
    }
}
