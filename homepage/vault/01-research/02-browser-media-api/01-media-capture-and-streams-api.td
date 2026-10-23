
The **Media Capture and Streams API** (also called the **Media Stream API**) is a browser API for capturing audio and video from the user's device (camera, microphone, screen). It produces streams of media tracks that can be played locally, recorded, or sent to a remote peer via WebRTC. It does not handle transmission or playback by itself; its role is purely capture.

It complements the WebRTC API: WebRTC sets up the peer connection and transfers media, but has no way to acquire a stream from hardware. The Media Capture API fills that gap by defining:

- How to request device access.
- How the resulting data is represented as a stream of tracks.
- How to control those tracks (mute, stop, switch device).

Once you have a `MediaStream`, you can pipe it anywhere:

- A `<video>` element for local preview.
- A `MediaRecorder` for recording.
- `RTCPeerConnection.addTrack()` to send it to a peer.

```
camera/mic/screen
         |
  getUserMedia()/getDisplayMedia()
         |
  MediaStream/MediaStreamTrack
         |
    +----+----+----+
    |         |    |
<video>  MediaRecorder  pc.addTrack()
```

## References

- MDN: https://developer.mozilla.org/en-US/docs/Web/API/Media_Capture_and_Streams_API

## Concepts

The API is built around a handful of core concepts that model how media data flows from a device to a consumer.

| Term | Web API | Meaning |
|---|---|---|
| Stream | `MediaStream` | A flux of audio/video data with one input and one output. A stream contains **zero or more tracks**. |
| Track | `MediaStreamTrack` | A **single audio or video source** within **a stream**. A track carries **one or more channels**. |
| Channel | (no dedicated object) | A single signal within a track (e.g., a stereo audio track has two channels: left and right speaker). |
| Input | (source of a `MediaStream`) | Where the stream originates: local device (camera, mic, screen) or non-local source. |
| Output/Consumer | (sink of a `MediaStream`) | Where the stream is consumed: media element, WebRTC peer connection, recorder, or audio processor. |

A stream's input is either **local** or **non-local**:

- **Local**: created from `getUserMedia()`/`getDisplayMedia()`, sourced directly from the user's hardware (camera, mic, screen).
- **Non-local**: sourced from elsewhere: a media element, a remote WebRTC peer, or a Web Audio node.

### Media Stream

[`MediaStream`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream) is the central object of the API, representing a flux of audio or video data. All other concepts are built around acquiring, transforming, or consuming it.

- Contains zero or more `MediaStreamTrack` objects.
- Has a single **input** and a single **output**.

### Track

A [`MediaStreamTrack`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack) represents a single audio or video source within a `MediaStream`.

- Has a `kind`: `"audio"` or `"video"`.
- Has one or more **channels**.
- Can be individually muted (`enabled = false`), stopped (`stop()`), or replaced (via `RTCRtpSender.replaceTrack()`).

### Channel

A channel is the smallest unit of a media stream, carried within a track.

- Example: a stereo audio track has two channels (left and right speaker).
- A mono audio track has one channel.
- Channels are not directly exposed as objects in the API; they are an internal property of a track.

### Input

Where a `MediaStream` originates. A stream has exactly one input.

- **Local**: from `getUserMedia()` or `getDisplayMedia()`, sourced from the user's camera, microphone, or screen.
- **Non-local**:
  - A media element (`<video>`, `<audio>`).
  - A WebRTC `RTCPeerConnection` (stream received from a remote peer).
  - A Web Audio API `MediaStreamAudioDestinationNode`.

### Output/Consumer

Where the `MediaStream` is consumed. A stream has exactly one output, connected to a consumer.

- A media element (`<audio>`, `<video>`) for playback.
- A WebRTC `RTCPeerConnection` to send to a remote peer.
- A Web Audio API `MediaStreamAudioSourceNode` for audio processing.
- A `MediaRecorder` for recording.

### Constraints, Capabilities, and Settings

Three related concepts that control what the device produces:

| Term | API | Meaning |
|---|---|---|
| Constraints | `getUserMedia(constraints)`, `track.applyConstraints()` | What you request from the device (resolution, frame rate, echo cancellation, etc.). |
| Capabilities | `track.getCapabilities()` | What the device actually supports (e.g., min/max resolution, supported frame rates). |
| Settings | `track.getSettings()` | What is currently applied after the browser resolves constraints against capabilities. |

Constraints can be **exact** or **ideal**:

- `exact`: the browser must satisfy this or throw `OverconstrainedError`.
- `ideal`: the browser gets as close as possible; never throws.

```js
// ideal: pick closest match, no error if not exact
getUserMedia({ video: { width: { ideal: 1280 }, frameRate: { ideal: 30 } } });

// exact: must match or fail
getUserMedia({ video: { width: { exact: 1920 } } });
```

## Web API

- [`navigator.mediaDevices`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices): Entry point for accessing input devices. Available on secure contexts (HTTPS) only.
  - `getUserMedia(constraints)`: Requests access to hardware input devices (camera, microphone).
    - Browser shows an allow/deny prompt.
    - Returns `Promise<MediaStream>`.
  - `getDisplayMedia(constraints)`: Requests screen capture (tab, window, or display).
    - Separate from `getUserMedia()` because screen capture has different privacy implications.
    - Browser shows a picker UI instead of a simple allow/deny prompt.
    - Returns `Promise<MediaStream>`.
  - `enumerateDevices()`: Lists available input/output devices.
    - Returns `Promise<MediaDeviceInfo[]>`.
  - Events: `devicechange` - fired when a device is added or removed.
- [`window.MediaStream`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream): Represents a stream of audio/video data.
  - `getTracks()`/`getAudioTracks()`/`getVideoTracks()`: Returns tracks by kind.
  - `addTrack(track)`/`removeTrack(track)`: Modify tracks in the stream.
  - `clone()`: Creates a copy of the stream with cloned tracks.
  - Events: `addtrack`, `removetrack`: fired when tracks are added/removed via `addTrack()`/`removeTrack()`. Not fired when a track ends naturally (e.g. device disconnected). Listen to `track.ended` for that.
- [`window.MediaStreamTrack`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack): Represents a single audio or video track.
  - `kind`: `"audio"` or `"video"`.
  - `enabled`: mute/unmute by toggling.
  - `readyState`: `"live"` or `"ended"`.
  - `stop()`: Stops the track and releases the underlying device.
  - `getConstraints()`/`applyConstraints(constraints)`: Read or update track constraints (resolution, frame rate, etc.).
  - `getCapabilities()`: Returns what the device supports.
  - `getSettings()`: Returns currently applied settings.
  - Events: `ended`, `mute`, `unmute`.
- [`window.MediaDeviceInfo`](https://developer.mozilla.org/en-US/docs/Web/API/MediaDeviceInfo): Describes an available media device.
  - `deviceId`, `groupId`, `kind` (`"audioinput"`, `"audiooutput"`, `"videoinput"`), `label`.
- [`HTMLMediaElement.captureStream()`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/captureStream): Captures a `MediaStream` from a `<video>` or `<audio>` element.
- [`HTMLCanvasElement.captureStream(frameRate?)`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/captureStream): Captures a `MediaStream` from a `<canvas>` element at a given frame rate.

## Common Scenarios

### Capture camera and mic, preview locally

```js
const stream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
videoElement.srcObject = stream;
```

### Capture with constraints

```js
const stream = await navigator.mediaDevices.getUserMedia({
  video: { width: { ideal: 1280 }, height: { ideal: 720 }, frameRate: { ideal: 30 } },
  audio: { echoCancellation: true, noiseSuppression: true },
});
```

### Switch camera (front/back on mobile)

```js
const stream = await navigator.mediaDevices.getUserMedia({
  video: { facingMode: "user" },   // "environment" for back camera
});
```

### List available devices

```js
const devices = await navigator.mediaDevices.enumerateDevices();
const cameras = devices.filter(d => d.kind === "videoinput");
```

### Send to a WebRTC peer

```js
for (const track of stream.getTracks()) {
  pc.addTrack(track, stream);
}
```

### Stop capture and release device

```js
for (const track of stream.getTracks()) {
  track.stop(); // releases the camera/mic indicator light
}
```

## Pitfalls

- **HTTPS only**: `getUserMedia()` and `getDisplayMedia()` only work on secure contexts. Fails silently or throws on `http://`.
- **Always stop tracks on cleanup**: not calling `track.stop()` keeps the device open (camera light stays on, mic stays active).
- **Permission errors**: handle `NotAllowedError` (user denied) and `NotFoundError` (no device found) explicitly.
- **`OverconstrainedError`**: thrown when no device can satisfy the requested constraints. Use `ideal` instead of exact values where possible to let the browser pick the closest match.
- **`enumerateDevices()` before permission**: device labels are empty strings until the user grants permission. Request `getUserMedia()` first.
- **Track vs stream lifetime**: stopping a track does not remove it from the stream. Check `track.readyState === "ended"` if you need to know if a track is still live.
