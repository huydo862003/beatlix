
> Source: https://developers.soundcloud.com/docs/api/html5-widget

The **SoundCloud Widget API** embeds a SoundCloud player as an `<iframe>` and gives you JavaScript control over it.

Key characteristics:

- This is the embedded player model where SoundCloud renders its own UI.
- You control the player via `postMessage`, wrapped by the `SC.Widget` object.
- There is no direct access to the audio stream.
- No authentication is needed for publicly streamable tracks.

## Playback API

```
Your page
  --> embeds <iframe src="https://w.soundcloud.com/player/?url=...">
  --> loads https://w.soundcloud.com/player/api.js
  --> SC.Widget(iframeElement) creates a controller
  --> communicate via postMessage
```

```html
<iframe id="sc-player"
  src="https://w.soundcloud.com/player/?url=https://soundcloud.com/artist/track&auto_play=false"
  width="100%" height="166">
</iframe>

<script src="https://w.soundcloud.com/player/api.js"></script>
<script>
  const widget = SC.Widget(document.getElementById("sc-player"));

  widget.bind(SC.Widget.Events.READY, () => {
    widget.play();
  });

  widget.bind(SC.Widget.Events.PLAY_PROGRESS, (e) => {
    console.log(e.currentPosition, e.loadedProgress);
  });
</script>
```

### Iframe URL parameters

| Parameter | Default | Meaning |
|---|---|---|
| `auto_play` | false | Start playing on load. |
| `color` | `#ff5500` | Hex color for player controls. |
| `buying` | true | Show buy link. |
| `sharing` | true | Show share button. |
| `download` | true | Show download button if track allows. |
| `show_artwork` | true | Show artwork. |
| `show_playcount` | true | Show play count. |
| `show_user` | true | Show uploader name. |
| `start_track` | 0 | Track index to start on, for playlists. |
| `single_active` | true | Pause other widgets on page when this one plays. |

## Key Methods

**Playback control (synchronous):**

- `play()`, `pause()`, `toggle()`
- `seekTo(milliseconds)`
- `setVolume(0-100)`
- `next()`, `prev()`: navigate playlist.
- `skip(soundIndex)`: jump to track index in playlist.

**State getters (asynchronous, callback-based):**

- `getVolume(cb)`, `getDuration(cb)`, `getPosition(cb)`
- `getSounds(cb)`: all tracks in the player.
- `getCurrentSound(cb)`: currently loaded track.
- `getCurrentSoundIndex(cb)`: current index in playlist.
- `isPaused(cb)`

All getters are async because they communicate via `postMessage`. Pass a callback, do not use the return value synchronously.

## Events

**Audio events:**

| Event | Fires when |
|---|---|
| `SC.Widget.Events.PLAY` | Playback starts. |
| `SC.Widget.Events.PAUSE` | Playback pauses. |
| `SC.Widget.Events.FINISH` | Track ends. |
| `SC.Widget.Events.SEEK` | User seeks. Provides `currentPosition`. |
| `SC.Widget.Events.PLAY_PROGRESS` | Periodic during playback. Provides `currentPosition`, `loadedProgress`, `relativePosition`. |
| `SC.Widget.Events.LOAD_PROGRESS` | Buffer progress. |

**UI events:**

| Event | Fires when |
|---|---|
| `SC.Widget.Events.READY` | Widget initialized, ready for commands. |
| `SC.Widget.Events.ERROR` | Playback error. |
| `SC.Widget.Events.CLICK_DOWNLOAD` | User clicks download. |
| `SC.Widget.Events.CLICK_BUY` | User clicks buy. |
| `SC.Widget.Events.OPEN_SHARE_PANEL` | User opens share panel. |

```js
widget.bind(SC.Widget.Events.PLAY_PROGRESS, handler);
widget.unbind(SC.Widget.Events.PLAY_PROGRESS);
```

## Authentication

No authentication is needed for publicly streamable tracks. Private tracks require a `secret_token` appended to the iframe URL, which you obtain via the SoundCloud API using a user-delegated OAuth token.

## Licensing and ToS

Restrictions from the [SoundCloud Terms of Use](https://developers.soundcloud.com/docs/api/terms-of-use):

- **No stream capture**: you cannot intercept or record the audio stream from the iframe.
- **Attribution required**: you must display the uploader's name, credit SoundCloud as the source, and include a visible backlink to the track on soundcloud.com.
- **No alternative service**: you cannot aggregate multiple artists' tracks into a competing streaming service.
- **Session caching only**: you must not persist audio or metadata beyond the current session.

Checklist:

- [ ] Uploader name (`user.username`) and link (`user.permalink_url`) are shown next to the player.
- [ ] Track links back to SoundCloud (`permalink_url`).
- [ ] SoundCloud logo in the widget is not hidden.
- [ ] No attempt to intercept the audio stream.
- [ ] Tracks are not aggregated into a standalone catalog.

## Pitfalls

- **All getters are async** because they communicate via `postMessage`. You cannot call `getPosition()` or `getDuration()` and use the result synchronously; always pass a callback.
- **`READY` must fire before calling any methods**. Calling `play()` or `seekTo()` before `READY` fires does nothing, so always bind `READY` first.
- **Filter by `access=playable` in your search queries**, since tracks with `access: "preview"` or `access: "blocked"` will not play fully in the widget.
- **Playlist and single-track URLs behave differently**. Check `getSounds()` after `READY` to know how many tracks are loaded.
- **`stream_url` from the search API cannot be used directly in `<audio>`** because it requires an OAuth token appended. Use the Widget API for browser playback instead.
- **Your API client ID may be revoked** because SoundCloud has closed registrations before. If the Widget API loads but the iframe returns errors, verify your client ID is still valid.
- **You cannot stream to a shared audience**. Even though many SoundCloud tracks are freely streamable, the ToS prohibits rebroadcasting or relaying audio from one user's session to others. Each listener must access the stream directly through the Widget API. There is no official group listening feature on SoundCloud.
