import SwiftUI

struct SettingsView: View {
    @AppStorage("streamingQuality") private var streamingQuality = "Normal"
    @AppStorage("downloadOverWifiOnly") private var wifiOnly = true
    private let qualities = ["Niedrig", "Normal", "Hoch"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    Text("Einstellungen")
                        .font(Theme.Font.largeTitle())
                        .foregroundStyle(Theme.Color.textPrimary)

                    settingsSection("WIEDERGABE") {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Streaming-Qualität")
                                Spacer()
                                Picker("", selection: $streamingQuality) {
                                    ForEach(qualities, id: \.self) { quality in
                                        Text(quality).tag(quality)
                                    }
                                }
                                .labelsHidden()
                                .tint(Theme.Color.accent)
                            }
                            .padding(16)

                            Divider().overlay(Theme.Color.divider)

                            Toggle(isOn: $wifiOnly) {
                                Text("Nur über WLAN herunterladen")
                            }
                            .tint(Theme.Color.accent)
                            .padding(16)
                        }
                        .background(Theme.Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    settingsSection("MUSIKQUELLEN") {
                        VStack(alignment: .leading, spacing: 12) {
                            sourceRow(icon: "music.note.list", title: "Spotify", detail: "Offizieller Web-/Embed-Player")
                            sourceRow(icon: "waveform", title: "SoundCloud", detail: "Offizieller Web-/Widget-Player")
                            Text("Spotify und SoundCloud werden direkt über ihre eigenen Player geöffnet. Die App erzeugt keine 30-Sekunden-Vorschau-URLs.")
                                .font(Theme.Font.caption())
                                .foregroundStyle(Theme.Color.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(Theme.Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    settingsSection("ÜBER") {
                        VStack(spacing: 0) {
                            LabeledContent("Version", value: "1.1.0")
                                .padding(16)
                        }
                        .background(Theme.Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Theme.Color.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.Font.caption())
                .foregroundStyle(Theme.Color.textSecondary)
                .padding(.horizontal, 4)
            content()
        }
    }

    private func sourceRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Color.accent)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Font.subheading())
                    .foregroundStyle(Theme.Color.textPrimary)
                Text(detail)
                    .font(Theme.Font.caption())
                    .foregroundStyle(Theme.Color.textSecondary)
            }
            Spacer()
        }
    }
}
