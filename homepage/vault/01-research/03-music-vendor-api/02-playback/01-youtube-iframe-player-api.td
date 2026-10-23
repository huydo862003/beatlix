
> Source: https://developers.google.com/youtube/iframe_api_reference

The **YouTube IFrame Player API** embeds a YouTube player in your page as an `<iframe>` and gives you JavaScript control over it. It is the only sanctioned way to play YouTube videos in a web app.

Key characteristics:

- This is the embedded player model where YouTube renders its own UI inside the iframe.
- You control the player via `postMessage`, wrapped by the `YT.Player` object.
- There is no direct access to the audio/video stream.
- No authentication is needed for public videos.

## Playback API

```
Your page
  --> loads https://www.youtube.com/iframe_api
  --> creates YT.Player(domElement, { videoId, events })
  --> <iframe src="https://www.youtube.com/embed/<videoId>"> rendered
  --> communicate via postMessage
```

Setup follows four steps:

1. Load the API script asynchronously.
2. Implement `window.onYouTubeIframeAPIReady`, which the API calls once the script is ready.
3. Create a `YT.Player` instance targeting a DOM element.
4. Control playback via methods and respond to state changes via events.

```js
const tag = document.createElement("script");
tag.src = "https://www.youtube.com/iframe_api";
document.head.appendChild(tag);

window.onYouTubeIframeAPIReady = function() {
  const player = new YT.Player("player-container", {
    videoId: "dQw4w9WgXcQ",
    playerVars: { autoplay: 0, controls: 1 },
    events: {
      onReady: (e) => e.target.playVideo(),
      onStateChange: (e) => console.log(e.data),
      onError: (e) => console.error(e.data),
    },
  });
};
```

## Key Methods

**Playback control:**

- `playVideo()`, `pauseVideo()`, `stopVideo()`
- `seekTo(seconds, allowSeekAhead)`: `allowSeekAhead=true` fetches new segments if needed.
- `setVolume(0-100)`, `mute()`, `unMute()`
- `setPlaybackRate(rate)`: 0.25, 0.5, 1, 1.5, 2.

**Loading content:**

- `loadVideoById(videoId)`: load and play immediately.
- `cueVideoById(videoId)`: load without playing.
- `loadPlaylist(playlist)`: load and play a playlist.

**State getters:**

- `getPlayerState()`: `-1` unstarted, `0` ended, `1` playing, `2` paused, `3` buffering, `5` cued.
- `getCurrentTime()`: seconds elapsed.
- `getDuration()`: total seconds. Returns `0` until metadata loads.
- `getVideoLoadedFraction()`: 0-1, how much is buffered.

## Events

| Event | Fires when |
|---|---|
| `onReady` | Player initialized, ready for commands. |
| `onStateChange` | State changes. `event.data` is the state number. |
| `onError` | Error. Codes: `2`=invalid ID, `5`=HTML5 error, `100`=not found, `101`/`150`=embedding disabled. |
| `onPlaybackQualityChange` | Video quality changes. |
| `onPlaybackRateChange` | Playback speed changes. |
| `onAutoplayBlocked` | Browser blocked autoplay. |

## Authentication

No API key or OAuth is needed for public videos. Private and age-restricted videos cannot play in embedded players regardless of authentication.

## Licensing and ToS

- **No stream capture**: do not intercept or record the video/audio stream from the iframe.
- **No UI modification**: do not hide or replace YouTube's branding or watermark.
- **Embedding must be enabled**: video owners can disable embedding. Error `101`/`150` means it is disabled.
- **Always set `origin`**: include your domain as the `origin` parameter in the player URL to prevent clickjacking.
- **No charging for access**: you cannot charge users for access to YouTube content.

Checklist:

- [ ] `origin` is set to your domain in the player URL.
- [ ] YouTube logo and watermark are not hidden.
- [ ] No attempt to extract the video URL or audio stream from the iframe.
- [ ] Thumbnails and titles outside the player link back to the YouTube watch page.

## Pitfalls

- **`getDuration()` returns 0 initially** because metadata is not available until playback starts. Wait for `onStateChange` (state `1`) before reading duration.
- **Autoplay is blocked by browsers**, so do not call `playVideo()` on `onReady` without a prior user gesture. Listen for `onAutoplayBlocked` instead.
- **`onYouTubeIframeAPIReady` is global and fires only once**. If you need multiple players, create all of them inside that single callback.
- **Embedding can be disabled by the video owner**. If you get error `101` or `150`, there is no workaround and you should skip that video.
- **iOS restricts autoplay and inline playback**. You need `webkit-playsinline` for inline playback on older iOS versions.
