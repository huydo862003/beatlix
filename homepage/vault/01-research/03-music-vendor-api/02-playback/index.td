---
_label: "Playback"
_icon: icon.folder
---

[[directory-index]]

Playback APIs let you stream audio from a provider's catalog in the browser. You cannot fetch the audio file directly. Providers protect content behind licensed players or streaming tokens. There are two models:

- **Embedded player**: the provider renders an `<iframe>` with their own UI, and you control it via `postMessage`. Control is limited but reliable, and the UI belongs to the provider.
- **SDK-based streaming**: the provider's SDK streams audio directly into the browser, and you build your own UI. This gives you full control over playback state but requires more integration effort and often a premium account.

## Problems

### Copyright and DRM

Audio streams are licensed. Any attempt to capture them violates both the ToS and copyright law.

All three providers prohibit:

- Downloading or permanently storing audio.
- Recording or ripping streams.
- Synchronizing audio with visual media without separate licenses.
- Using audio to train ML/AI models.

### Authentication

| Provider | Requirement |
|---|---|
| YouTube IFrame | No auth for public videos. Browser loads the player from YouTube directly. |
| Spotify SDK | User OAuth token with `streaming` scope. User must have Spotify Premium. |
| SoundCloud Widget | No auth for public tracks. Private tracks require a `secret_token` in the iframe URL. |

### User Account Requirements

| Provider | Requirement |
|---|---|
| YouTube | No account needed for public content. |
| Spotify | Premium required. Free users are limited to 30-second `preview_url` clips. |
| SoundCloud | No account needed for publicly streamable tracks. |

### What You Can and Cannot Control

| | YouTube IFrame | Spotify SDK | SoundCloud Widget |
|---|---|---|---|
| Custom UI | No | Yes | No |
| Play/pause/seek | Yes | Yes | Yes |
| Volume | Yes | Yes | Yes |
| Playback events | Yes | Yes | Yes |
| Queue management | Limited | Yes | Limited |
| Full track | Yes (video+audio) | Yes (audio only) | Yes (audio only) |
| Offline/download | No | No | No |

## Per Provider

- [**YouTube IFrame Player API**](01-youtube-iframe-player-api)
- [**Spotify Web Playback SDK**](02-spotify-web-playback-sdk)
- [**SoundCloud Widget API**](03-soundcloud-widget-api)
