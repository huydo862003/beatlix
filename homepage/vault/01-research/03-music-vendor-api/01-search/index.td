---
_label: "Search"
_icon: icon.folder
---

[[directory-index]]

**Search APIs** give you **structured access** to **a provider's catalog**: You query by keyword and get back metadata (title, artist, album, IDs).

> The IDs drive playback, so search always comes first.

::: warning

You **CANNOT** scrape this data.
- Providers require API access because the content is licensed.
- Providers' ToS governs what you can do with the results.

:::

## Problems

There are some common problems regarding the uses of search APIs.

### Authentication

All **3 providers** use **OAuth 2.0**, but _the flow you need_ depends on what you are doing. The following are some common flows.

#### Client Credentials (app-only)

::: note
When you register your app on a provider's developer portal (Google Cloud Console, Spotify Developer Dashboard, SoundCloud Developer Portal), you receive a **client ID** and a **client secret**:

- **Client ID**: public. Identifies which app is making requests. Safe to include in frontend code.
- **Client secret**: confidential. Must stay on your server. Anyone with your secret can make API calls as your app and consume your quota.
:::

- **Mechanism**: your app authenticates with its client ID and secret, with no user involved:
  1. Before deployment: You register your app on the provider's developer portal and receive a client ID and client secret.
  2. Your backend sends a POST request to the provider's token endpoint with your client ID and secret.
  3. The provider returns an access token that represents the app.
- **Use cases**:
  - **Public catalog search** on Spotify and SoundCloud.
- **Limitations**:
  - The token represents the app, not a user, so you cannot access user-specific data with it.
  - Because the client secret must stay on the server, you cannot use this flow from the browser directly. Your backend must act as a proxy:
    ```
        Browser --> your backend --> provider API (with token)
    ```

#### Authorization Code (user-delegated)

- **Mechanism**: the user grants your app permission via a browser redirect. The flow has four steps:
  1. Before deployment: you register your app on the provider's developer portal, receive a client ID and secret, and configure a redirect URI.
  2. Your app redirects the user to the provider's authorization URL, including your client ID and the scopes you need.
    > The URL has client ID, scopes,  redirect URI in the query params
  3. The user logs in and approves the requested permissions on the provider's page.
  4. The provider redirects the user back to your redirect URI with a short-lived **authorization code** in the query string.
    > The authorization code is single-use and expires within minutes, so your backend must exchange it immediately.
  5. Your backend calls the provider's token endpoint with the authorization code and your client secret, and receives an **access token** and usually a **refresh token** in return.
    > Access tokens expire (typically in 1 hour). You use the refresh token to get a new access token without requiring the user to log in again.
- **Use cases**:
  - User-specific operations like accessing their library, private playlists, or upload history.
- **Limitations**:
  - Requires a browser redirect, so the user must leave your page and return before your app can make user-scoped calls.
  - Tokens are scoped to the permissions (scopes) the user approved. If your app later needs a new scope, the user must go through the flow again.

#### API Key

- **Mechanism**: YouTube's model for public search. No OAuth needed:
  1. You register your app on Google Cloud Console and create an API key.
  2. You append `?key=YOUR_API_KEY` to every request URL.
  3. Google identifies your app by the key and charges the request against your quota.
- **Use cases**:
  - Read-only access to public data (search, video metadata).
- **Limitations**:
  - Only works for public data. User-specific operations still require OAuth.
  - The key is tied to your quota, so keep it private to avoid others consuming your daily units.

### Rate Limiting

Each provider uses a different quota model.

#### YouTube

- **Model**: unit-based daily quota. Each API call costs a fixed number of units.
- **Limit**: 10,000 units/day.
- **On exceed**: `403 quotaExceeded`.
- **Endpoint costs differ**:
  - `search.list` searches the catalog by keyword and costs 100 units per call.
  - `videos.list` fetches metadata for specific video IDs you already know and costs only 1 unit.
  - At 10,000 units/day you can make 100 keyword searches but thousands of metadata lookups.
  - The typical pattern is to call `search.list` to get IDs, then `videos.list` to get richer metadata for those IDs.
- **Reset time**: midnight Pacific time, not 24 hours from your first call. If you exhaust your quota at 11pm PT, it resets in one hour.

::: warning **The quota is tight at scale**

At 100 searches/day, a single moderately active app can exhaust it quickly.

-> Some bots work around this by calling YouTube's internal Innertube API (`youtubei/v1/search`), rotating across multiple API keys, or shelling out to `yt-dlp`, all of which violate YouTube's ToS.

The legitimate options are aggressive session-level caching, applying for a quota increase via Google Cloud Console, or falling back to SoundCloud/Spotify for common tracks.
:::

#### Spotify

- **Model**: request-based. Limit is unpublished.
- **On exceed**: `429 Too Many Requests` with a `Retry-After` header that tells you exactly how many seconds to wait. Use it to implement reliable backoff.

#### SoundCloud

- **Model**: request-based. Limit is unpublished and can change without notice.
- **On exceed**: `429`, with no `Retry-After` header. Use exponential backoff as the safe default.

### Licensing and ToS

What comes back from a search is metadata, not audio. But even metadata has restrictions:

- **No persistent caching**:
  - You may not store search results in a database or on disk across sessions.
  - Keep them in memory for the current session only and re-query the next time the user searches.
  - This is because the provider's catalog changes and they require fresh, attributed results.
- **Attribution required**: whenever you display search results, you must show the provider's branding (logo, name) and link each result back to its page on the provider's platform. You cannot strip that context and present results as your own.
- **No AI training**: you cannot feed search results (titles, metadata, IDs) into a machine learning model. All three providers explicitly prohibit this in their ToS.
- **No alternative service**: you cannot use the API to build something that competes with the provider itself. The APIs are licensed so your app can offer search and discovery as a feature, not so you can replicate what those platforms already do.
  - Using search to find tracks for a playlist feature is fine.
  - Building a music search frontend as the core product is not.

### Data Model Differences

Each provider represents a "track" differently:

- **Spotify**: ISRC codes, market availability, clean artist/album objects, `preview_url`.
- **YouTube**: video metadata only. No ISRC, album, or track number.
- **SoundCloud**: genre, BPM, waveform data, `access` field for playability.

## Per Provider

- [**YouTube Data API**](01-youtube-data-api)
- [**Spotify Web API**](02-spotify-web-api)
- [**SoundCloud API**](03-soundcloud-api)
