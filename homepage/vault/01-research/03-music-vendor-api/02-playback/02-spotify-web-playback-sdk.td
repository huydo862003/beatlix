
> Source: https://developer.spotify.com/documentation/web-playback-sdk

The **Spotify Web Playback SDK** streams Spotify audio directly into the browser and registers your app as a **Spotify Connect device**. You build your own player UI. The SDK handles audio streaming and DRM.

Key characteristics:

- This is the SDK-based streaming model, giving you full control over playback state.
- Requires a user OAuth token with the `streaming` scope.
- Requires **Spotify Premium** with no workaround for free users.
- The device appears in the user's Spotify app under "Connect to a device", and playback can be transferred to and from other devices at any time.

## Playback API

```
User's browser
  --> loads Spotify Web Playback SDK script
  --> SDK registers as a Spotify Connect device
  --> user or app transfers playback to this device
  --> SDK streams audio from Spotify's CDN
  --> you control playback via SDK methods
  --> you receive state via events
```

```js
window.onSpotifyWebPlaybackSDKReady = () => {
  const player = new Spotify.Player({
    name: "My Web Player",
    getOAuthToken: (cb) => cb(accessToken),
    volume: 0.5,
  });

  player.addListener("ready", ({ device_id }) => {
    fetch("https://api.spotify.com/v1/me/player", {
      method: "PUT",
      headers: { Authorization: `Bearer ${accessToken}` },
      body: JSON.stringify({ device_ids: [device_id], play: true }),
    });
  });

  player.addListener("player_state_changed", (state) => {
    console.log(state);
  });

  player.connect();
};
```

## Key Methods

- `connect()`: registers the device. Returns `Promise<boolean>`.
- `disconnect()`: unregisters and frees resources.
- `play({ uris?, context_uri?, offset? })`: start or resume. Pass `uris` for specific tracks.
- `pause()`, `togglePlay()`
- `nextTrack()`, `previousTrack()`
- `seek(positionMs)`: seek in milliseconds.
- `setVolume(0-1)`: note the 0-1 range, not 0-100.
- `getVolume()`: `Promise<number>`.
- `getCurrentState()`: `Promise<WebPlaybackState|null>`. Returns `null` if the player is not the active device.

## Events

| Event | Fires when |
|---|---|
| `ready` | Device registered. Provides `device_id`. |
| `not_ready` | Device went offline. |
| `player_state_changed` | State changes: track, position, paused, shuffle, repeat, queue. |
| `autoplay_failed` | Browser blocked autoplay. |

State object from `player_state_changed`:

```js
{
  track_window: {
    current_track: { id, name, artists, album, duration_ms },
    next_tracks: [...],
    previous_tracks: [...],
  },
  position: 12345,    // ms
  duration: 240000,   // ms
  paused: false,
  shuffle: false,
  repeat_mode: 0,     // 0=off, 1=context, 2=track
}
```

## Authentication

Requires Authorization Code flow with these scopes:

```
streaming
user-read-playback-state
user-modify-playback-state
```

The token is passed via the `getOAuthToken` callback. The SDK calls this whenever it needs a fresh token, so implement your token refresh logic inside this callback.

The SDK requires **Spotify Premium**. Free accounts cannot use it.

- Always check `user.product === "premium"` via the Web API before initializing the SDK.
- For free users, `preview_url` (30-second clips from the search API) is the only playback option.


## Licensing and ToS

Restrictions from the [Spotify Developer Policy](https://developer.spotify.com/policy):

- **No commercial use without approval**: the SDK cannot be used in commercial projects without Spotify's prior written approval.
- **No downloading**: you cannot capture, record, or store the audio stream.
- **No sync licensing**: you cannot synchronize Spotify audio with visual media (videos, games, films).
- **No broadcasting**: you cannot re-stream or rebroadcast Spotify audio.
- **No AI training**: Spotify content cannot be used to train ML/AI models.

Checklist:

- [ ] Premium is verified before initializing the SDK.
- [ ] No attempt to intercept or record the audio stream.
- [ ] Spotify attribution is displayed. Track links back to Spotify.
- [ ] SDK is not used in a commercial product without contacting Spotify first.

## Pitfalls

- **The Premium check is the most common miss**. Always verify `user.product === "premium"` before calling `connect()`.
- **`device_id` changes on every `connect()` call**, so do not cache it. Always read it from the `ready` event.
- **iOS does not autoplay after playback transfer**. The user must interact with the page first, so listen for `autoplay_failed` and prompt them.
- **`getOAuthToken` is called synchronously**, so your token refresh logic must be fast. If it is async, wrap it carefully to avoid blocking the SDK.
- **Ad blockers frequently block the SDK script**, so handle load failures gracefully with a fallback message.
- **`getCurrentState()` can return null** when the player is not the active device. Always null-check before using the result.
- **Development mode caps at 25 users**. Apply for extended quota before scaling beyond a small team.
- **You cannot stream to a shared audience**. Spotify's ToS explicitly prohibits rebroadcasting audio to other users, even from a legitimate Premium account. Each listener must have their own Premium account and direct stream.
  - Discord bots like Jockie bypass this using `librespot`, a reverse-engineered Spotify client, which violates ToS and has led to repeated takedowns.
  - There is no official third-party equivalent to Spotify's own "Jam" and "Group Session" features.
- **"The user chose to share it" is not a valid defense**. Secondary liability applies if your platform is designed to facilitate music sharing, the same theory that shut down Napster and Grokster. Building infrastructure that enables infringement is enough; you do not need to directly infringe.
  - A general-purpose screen sharing tool (like Discord Go Live) sits in a grayer area.
  - A music-focused app where sharing is clearly built around music has a much weaker defense.
- **For synchronized group listening, use the Spotify Connect API instead of the SDK**. Each user plays through their own Spotify app. Your server sends sync commands via the Web API (`PUT /v1/me/player/play`, `PUT /v1/me/player/seek`).
  - No Premium requirement since users play through their own app.
  - Requires Authorization Code flow with `user-modify-playback-state` and `user-read-playback-state` scopes.
  - Tradeoff: higher latency on sync commands, no control over which device the user is listening on.
