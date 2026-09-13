# SpotifyClone

## Streaming changes

This build no longer uses the iTunes Search API and contains no Spotify/SoundCloud developer credentials.

### Search and playback
- The Search screen searches Spotify or SoundCloud using the provider's own web experience inside a WKWebView.
- Spotify/SoundCloud track URLs are opened with the official provider player/embed inside the app.
- No iTunes `previewUrl` / 30-second preview code remains.
- Normal text searches are not sent to iTunes or another catalog API.

### Important provider limitation
The app does not extract or proxy protected Spotify/SoundCloud audio streams. The provider controls account, region, premium/free, ad, and playback restrictions in its official player. Therefore the app cannot guarantee unrestricted full-track playback where the provider itself does not allow it.

## UI
- Settings uses a full-width ScrollView instead of the default grouped List layout.
- Navigation bars are hidden on the custom pages so content can use the complete available window.
- Root and tab content use flexible sizing instead of a fixed device-size canvas.
