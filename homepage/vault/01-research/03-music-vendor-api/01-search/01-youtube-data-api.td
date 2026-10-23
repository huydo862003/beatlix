
> Source: https://developers.google.com/youtube/v3/docs

The **YouTube Data API v3** gives you programmatic access to YouTube's catalog. For music, the main use is keyword search to get video IDs and snippet data, which you then pass to the IFrame Player API for playback.

- YouTube does not distinguish music from other video content, so results include covers, remixes, fan uploads, and official audio.
- There is no music-specific metadata like ISRC, album, or track number. You only get video metadata.
- The catalog is huge, but the tradeoff is messy, unstructured metadata.

## Authentication

For public search, an **API key** is all you need:

- Create one in Google Cloud Console and pass it as `key=` on every request.
- OAuth is only required for user-specific operations like `forMine=true`, uploading videos, or managing playlists.

## Search API

Search goes through a single endpoint, `GET /youtube/v3/search`:

```
GET https://www.googleapis.com/youtube/v3/search
  ?part=snippet
  &q=<query>
  &type=video
  &key=<API_KEY>
```

Key parameters:

- `part=snippet`: required. Tells the API to return title, description, channel, thumbnails, and publish date.
- `q`: the keyword query. Supports `-term` to exclude a term and `term|term` for OR.
- `type=video`: filters to videos only. Omit it to get mixed results including channels and playlists.
- `maxResults`: controls how many results to return, between 1 and 50. Defaults to 5.

### Response Shape

```json
{
  "kind": "youtube#searchListResponse",
  "nextPageToken": "...",
  "pageInfo": { "totalResults": 1000000, "resultsPerPage": 5 },
  "items": [
    {
      "id": { "kind": "youtube#video", "videoId": "dQw4w9WgXcQ" },
      "snippet": {
        "title": "...",
        "channelTitle": "...",
        "thumbnails": { "default": { "url": "..." } },
        "publishedAt": "2009-10-25T06:57:33Z"
      }
    }
  ]
}
```

The `videoId` is what you pass to the IFrame Player API.

### Pagination

- Use `pageToken` with the `nextPageToken`/`prevPageToken` values from the response.
- `totalResults` is an estimate, so do not display it as a precise count.

### Getting More Metadata

`search.list` returns snippet data only. For duration, view count, or content details, follow up with `videos.list`, which costs only 1 unit instead of 100:

```
GET https://www.googleapis.com/youtube/v3/videos
  ?part=contentDetails,statistics
  &id=<videoId>
  &key=<API_KEY>
```

## Rate Limiting

YouTube uses a **unit-based daily quota**. Each endpoint costs a different number of units:

| Operation | Cost |
|---|---|
| `search.list` | 100 units |
| `videos.list` | 1 unit |
| Default daily quota | 10,000 units |

- At the default quota, you can make at most 100 keyword searches per day.
- The quota resets at midnight Pacific Time, not 24 hours from your first call.
- If you exceed it, the API returns `403 quotaExceeded`.
- To raise the limit, submit a quota extension request in Google Cloud Console, though approval is not guaranteed.
- Debounce all search inputs so you do not fire a request on every keystroke.

## Licensing and ToS

Restrictions from the [YouTube API Terms of Service](https://developers.google.com/youtube/terms/api-services-terms-of-service):

- **No persistent caching**: you may only store results for the current session.
- **Attribution required**: follow YouTube Branding Guidelines and link thumbnails and titles back to `https://www.youtube.com/watch?v=<videoId>`.
- **No AI training**: API data cannot be used to train ML/AI models.
- **No quota circumvention**: you must not create multiple projects to bypass limits.

Checklist:

- [ ] Results are not stored to a database.
- [ ] Thumbnails and titles link back to YouTube.
- [ ] YouTube branding is not stripped from players or thumbnails.
- [ ] Search results are not used to build a competing video catalog.

## Pitfalls

- **`search.list` costs 100 units**, so use `videos.list` (1 unit) for any lookup by known ID. Only use `search.list` when you actually need keyword search.
- **`totalResults` is unreliable** and should not be shown as a precise total.
- **There is no music-only filter**. Results mix official audio, covers, remixes, and fan uploads with no way to filter for official content only.
- **Videos can be region-restricted**. Pass `regionCode` if you need region-aware results, since a video playable in one country may be blocked in another.
