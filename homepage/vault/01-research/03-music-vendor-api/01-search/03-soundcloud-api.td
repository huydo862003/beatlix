
> Source: https://developers.soundcloud.com/docs/api/reference

The **SoundCloud API** gives you access to SoundCloud's catalog of user-uploaded content: independent artists, demos, DJ sets, remixes, and podcasts.

Key characteristics:

- Covers content that is not commercially distributed on Spotify or YouTube.
- Audio-only platform with music-specific metadata like genre, BPM, and waveform data.
- Many tracks are freely streamable without a premium account.
- API access is gated, and registration has been closed to new applicants at various times.

## Search API

Search is split by resource type. For tracks:

```
GET https://api.soundcloud.com/tracks
  ?q=<query>
  &limit=10
  &linked_partitioning=true
Authorization: OAuth <access_token>
```

The same endpoint pattern is also available for `/users` and `/playlists`.

Key parameters:

- `q`: keyword query. Matches title, username, and description.
- `limit`: results per page. Default 50, max 200.
- `linked_partitioning=true`: enables cursor-based pagination via `next_href`.
- `genres`: comma-separated genre filter.
- `access`: filter by `playable`, `preview`, or `blocked`. Always use `playable` to exclude unplayable tracks.
- `bpm[from]`/`bpm[to]`: BPM range filter.
- `duration[from]`/`duration[to]`: duration range filter in milliseconds.

### Response Shape

```json
{
  "collection": [
    {
      "id": 1234567,
      "title": "Track Name",
      "duration": 240000,
      "genre": "electronic",
      "bpm": 128,
      "user": {
        "id": 99,
        "username": "artist_name",
        "permalink_url": "https://soundcloud.com/artist_name"
      },
      "permalink_url": "https://soundcloud.com/artist_name/track-name",
      "artwork_url": "https://i1.sndcdn.com/artworks-...-large.jpg",
      "stream_url": "https://api.soundcloud.com/tracks/1234567/stream",
      "access": "playable",
      "waveform_url": "https://wave.sndcdn.com/..."
    }
  ],
  "next_href": "https://api.soundcloud.com/tracks?q=...&cursor=..."
}
```

- `id`: the track identifier used for playback via the Widget API.
- `stream_url`: a direct stream endpoint that requires an appended OAuth token. Subject to ToS restrictions (see below).
- `waveform_url`: returns a JSON file with amplitude data, not a rendered image. You need to render the waveform visualization yourself.

### Pagination

Use `next_href` from the response to fetch the next page. When absent, no more results exist.

## Authentication

SoundCloud uses **OAuth 2.0**. All requests require `Authorization: OAuth <access_token>`.

For public catalog search, **Client Credentials** is supported:

```
POST https://api.soundcloud.com/oauth2/token
  grant_type=client_credentials
  &client_id=<CLIENT_ID>
  &client_secret=<CLIENT_SECRET>
```

Authorization Code flow is needed for user-specific operations like liking tracks, accessing private tracks, or uploading.

::: note
SoundCloud has closed API registration to new applicants at various times. Verify your application is approved before building on it.
:::

## Rate Limiting

SoundCloud does not publish specific limits. If you exceed them, the API returns `429 Too Many Requests` with no `Retry-After` header, so use exponential backoff as the safe default.

## Licensing and ToS

Restrictions from the [SoundCloud API Terms of Use](https://developers.soundcloud.com/docs/api/terms-of-use):

- **Session-based caching only**: cached content must become inaccessible when the session ends. No persistent storage.
- **No stream ripping**: cannot capture, copy, or permanently store audio, even if the uploader enabled downloads.
- **Attribution required**: credit the uploader as creator, credit SoundCloud as the source, and include a visible backlink to the track URL on soundcloud.com.
- **No alternative streaming service**: cannot aggregate multiple users' tracks into a competing streaming service.
- **No AI training**: API data cannot train ML/AI models.
- **No advertising integration**: cannot use tracks in ads, videos, or films without separate licenses.

Checklist:

- [ ] Uploader name (`user.username`) and link (`user.permalink_url`) are displayed alongside the track.
- [ ] Track links back to SoundCloud (`permalink_url`).
- [ ] Results are not stored beyond the current session.
- [ ] `stream_url` is not used to download or cache audio.
- [ ] Tracks are not aggregated into a catalog that replaces SoundCloud's interface.
- [ ] Track data is not used to train any ML model.

## Pitfalls

- **API access may be unavailable** because SoundCloud has closed registrations before. Confirm your client ID is still valid if the API returns unexpected errors.
- **Always filter by `access=playable`**, since blocked and preview-only tracks appear in search results by default.
- **`stream_url` cannot be used directly in an `<audio>` tag** because it requires the OAuth token appended. Use the Widget API for browser playback instead.
- **There is no market filtering**. SoundCloud has no per-country availability model, so a track can still be geoblocked at the CDN level even if the API returns it.
- **`waveform_url` is not an image** but a JSON file containing amplitude data. You need to render the waveform visualization yourself.
