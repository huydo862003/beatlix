---
_label: "Music Vendor API"
_icon: icon.folder
---

[[directory-index]]

External provider APIs for music. Split into two concerns: searching the catalog and playing back a track. Each has its own access model and constraints.

## General Idea

Music content on the web is licensed. You cannot freely stream or scrape it. Instead, providers (YouTube, Spotify, SoundCloud) offer APIs that let you search their catalog and trigger playback within the constraints of their licensing agreements.

The flow is always:

1. **Search**: query the provider's catalog by keyword, get back metadata and track IDs.
2. **Playback**: use the track ID to play the audio, either via an embedded player (YouTube IFrame, SoundCloud Widget) or a streaming SDK (Spotify Web Playback SDK, Spotify Connect API).

Each provider has different authentication requirements, quota models, and ToS restrictions. The research here covers what is allowed, what is not, and what the valid approaches are for a platform like Beatlix.

::: note
Beatlix is a general-purpose social platform (chat, screen sharing, activity sharing, live sessions) where music playback is one activity among many, not the core product. This positioning matters legally: it places Beatlix closer to Discord than to a dedicated music streaming app. The "no alternative service" clause and secondary liability concerns are significantly weaker when music is incidental to the platform's purpose. Avoid framing music features as the primary advertised use case.
:::

- [**Search**](01-search/index)
- [**Playback**](02-playback/index)

## What Not to Consider

These approaches appear viable but are not:

- **Rebroadcasting a user's stream to others**. All three providers prohibit it, even if the source account is legitimate. This applies whether you relay the audio yourself or build infrastructure that lets users do it.
- **"The user chose to share it"**. Secondary liability applies if your platform is designed to facilitate music sharing as a primary use case. Since Beatlix is a general-purpose social platform, this defense is much stronger here than it would be for a dedicated music app. The risk is low as long as music is not the advertised core feature.
- **Using internal APIs or reverse-engineered clients** (e.g. YouTube's Innertube, Spotify's `librespot`, `yt-dlp`). These violate ToS and providers actively shut down apps that rely on them.
- **Rotating API keys across multiple projects** to bypass quota limits. YouTube explicitly prohibits this.
- **Scraping metadata** instead of using the API. All three providers require API access because the content is licensed.
- **Storing search results or audio in a database**. All three providers require session-only caching.

## Valid Options

| Goal | YouTube | Spotify | SoundCloud |
|---|---|---|---|
| Public catalog search | API key | Client Credentials | Client Credentials |
| Full track playback in browser | IFrame Player API (embedded) | Web Playback SDK (Premium only) or Connect API | Widget API (embedded) |
| Synchronized group listening | Each user has their own IFrame player. Your server syncs play/pause/seek across the room. Well-established pattern used by Watch2Gether, SyncUp, Teleparty. | Each user plays via their own Spotify app. Your server sends `PUT /v1/me/player/play` and `PUT /v1/me/player/seek` to each client. No Premium requirement. Used by JQBX. | Each user has their own Widget instance. Your server syncs play/pause/seek across the room. Technically feasible but no established third-party example. |
| Free user playback | Yes, all public videos play freely | 30-second `preview_url` clips only (no full track) | Yes, most tracks are freely streamable |
| User-specific operations | OAuth (upload, playlists) | Authorization Code (library, playback control) | Authorization Code (likes, private tracks, upload) |
