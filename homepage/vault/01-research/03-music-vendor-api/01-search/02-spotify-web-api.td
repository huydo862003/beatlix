
> Source: https://developer.spotify.com/documentation/web-api

The **Spotify Web API** gives you structured access to Spotify's music catalog. Unlike YouTube, results map cleanly to real music entities with proper metadata.

Key characteristics:

- Proper music metadata: ISRC codes, album art, duration, artist IDs, release dates, market availability.
- Fully licensed commercial music. Results are catalog data, not audio.
- Playback requires the Web Playback SDK and a Spotify Premium account.

## Search API

Search goes through a single endpoint, `GET /v1/search`:

```
GET https://api.spotify.com/v1/search
  ?q=<query>
  &type=track,artist,album
  &market=US
  &limit=10
  &offset=0
Authorization: Bearer <access_token>
```

Key parameters:

- `q`: keyword query. Supports field filters: `artist:`, `album:`, `track:`, `year:`, `isrc:`, `genre:`. Example: `q=artist:radiohead+album:ok+computer`.
- `type`: comma-separated. Options: `track`, `artist`, `album`, `playlist`, `show`, `episode`, `audiobook`.
- `market`: ISO 3166-1 alpha-2 country code. Filters to content available in that market. Always pass this.
- `limit`: 0-50 per type, default 20.
- `offset`: 0-1000, used with `limit` for pagination.

### Response Shape

```json
{
  "tracks": {
    "total": 423,
    "next": "https://api.spotify.com/v1/search?...&offset=10",
    "previous": null,
    "items": [
      {
        "id": "4iV5W9uYEdYUVa79Axb7Rh",
        "name": "Creep",
        "duration_ms": 238640,
        "artists": [{ "id": "4Z8W4fKeB5YxbusRsdQVPb", "name": "Radiohead" }],
        "album": { "id": "...", "name": "Pablo Honey", "images": [...] },
        "external_ids": { "isrc": "GBAYE9200049" },
        "preview_url": "https://p.scdn.co/mp3-preview/...",
        "uri": "spotify:track:4iV5W9uYEdYUVa79Axb7Rh"
      }
    ]
  }
}
```

- `id`: the track identifier you pass to the Web Playback SDK for playback.
- `uri` (`spotify:track:<id>`): the Spotify URI used for direct playback commands.
- `preview_url`: a 30-second preview clip. Can be null for some tracks and is not a substitute for full playback.

### Pagination

Use the `next` and `previous` URLs from the response directly. `total` is accurate (unlike YouTube).

## Authentication

Spotify uses **OAuth 2.0**. For public catalog search, **Client Credentials** is enough:

```
POST https://accounts.spotify.com/api/token
  grant_type=client_credentials
  &client_id=<CLIENT_ID>
  &client_secret=<CLIENT_SECRET>
```

- The response contains an `access_token` valid for 3600 seconds.
- Attach it as `Authorization: Bearer <token>` on every request.
- Refresh it by repeating the same POST request before it expires.
- Authorization Code flow is only needed for user-specific operations like playback control, accessing the user library, or private playlists.

## Rate Limiting

Spotify does not publish specific limits. If you exceed them, the API returns `429 Too Many Requests` with a `Retry-After` header telling you how many seconds to wait.

### App tiers

- **Development mode**: your app is capped at 25 unique users. Additional users must be manually added to the allowlist in the developer dashboard. The app owner must have Spotify Premium.
- **Extended quota mode**: removes the user cap. To apply, you need a company email, proof of legal business registration, 250k+ monthly active users, and availability in key Spotify markets. Review takes up to six weeks.

## Licensing and ToS

Restrictions from the [Spotify Developer Policy](https://developer.spotify.com/policy):

- **No AI training**: content and metadata cannot be used to train ML/AI models.
- **No standalone preview service**: `preview_url` clips cannot serve as the basis of a standalone streaming service.
- **Attribution required**: show Spotify branding and do not present results as your own catalog.
- **No persistent caching**: do not store metadata in a database; use results transiently.
- **Market compliance**: only show content that is available in the user's market.

Checklist:

- [ ] `market` is always passed matching the user's country.
- [ ] `preview_url` is null-checked before use.
- [ ] Results are not stored to a database.
- [ ] Spotify attribution is displayed alongside results.
- [ ] Metadata is not used to train any ML model.

## Pitfalls

- **The development mode cap hits fast**. Add all testers to the allowlist early and apply for extended quota before you need it.
- **`preview_url` can be null** because not all tracks have a preview. Always null-check before using it.
- **Omitting `market` causes silent issues** where a track may appear in results but be unplayable in the user's region. Always pass it.
- **Tokens expire after 1 hour**. Implement token refresh before making requests, not after getting a `401`.
- **Free users cannot play full tracks**. The Web Playback SDK requires Spotify Premium, so free users can only access 30-second `preview_url` clips.
