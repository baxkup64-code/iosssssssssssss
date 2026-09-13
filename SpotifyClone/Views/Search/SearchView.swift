import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject private var player: PlayerViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                providerPicker
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, 10)
                    .padding(.bottom, 8)

                if let track = viewModel.results.tracks.first, track.sourceURL != nil {
                    nativeTrackResult(track)
                }

                ProviderSearchWebView(provider: viewModel.provider, query: viewModel.query)
                    .id("\(viewModel.provider.rawValue)-\(viewModel.query)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.Color.background)
            }
            .background(Theme.Color.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                header
                    .background(.ultraThinMaterial)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Suchen")
                .font(Theme.Font.largeTitle())
                .foregroundStyle(Theme.Color.textPrimary)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.Color.textSecondary)
                TextField("Spotify oder SoundCloud durchsuchen", text: $viewModel.query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundStyle(Theme.Color.textPrimary)
                    .onSubmit { viewModel.searchNow() }

                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                        viewModel.results = SearchResults()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.Color.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var providerPicker: some View {
        Picker("Musikquelle", selection: $viewModel.provider) {
            ForEach(MusicProvider.allCases) { provider in
                Text(provider.rawValue).tag(provider)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.provider) { _, _ in
            if !viewModel.query.isEmpty { viewModel.searchNow() }
        }
    }

    private func nativeTrackResult(_ track: Track) -> some View {
        Button {
            player.play(tracks: [track], startIndex: 0)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: track.source == .spotify ? "music.note.list" : "waveform")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Color.accent)
                    .frame(width: 44, height: 44)
                    .background(Theme.Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.source == .spotify ? "Spotify-Link erkannt" : "SoundCloud-Link erkannt")
                        .font(Theme.Font.subheading())
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text("Offiziellen Player öffnen")
                        .font(Theme.Font.caption())
                        .foregroundStyle(Theme.Color.textSecondary)
                }

                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.Color.accent)
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}
