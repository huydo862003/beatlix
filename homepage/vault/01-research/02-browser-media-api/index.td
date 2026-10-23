---
_label: "Browser Media API"
_icon: icon.folder
---

[[directory-index]]

Browser APIs for capturing and processing audio and video. Covers how to get media into the browser from different sources and how to process it before sending.

- [**Media Capture API**](01-media-capture-api)
- [**Web Audio API**](02-web-audio-api)

## General Idea

Before you can stream audio or video over WebRTC, you need to capture it from the user's device and optionally process it. Two browser APIs handle this:

- **Media Capture and Streams API** is the entry point. It gives you a `MediaStream` from the user's microphone, camera, or screen, which you then hand to WebRTC for streaming.
- **Web Audio API** lets you manipulate audio before it goes out: mixing, filtering, analysing levels, adding effects. You can tap into a `MediaStream`, process it through an audio graph, and pipe the result back into a stream for WebRTC.

Together these two APIs sit between the user's hardware and the WebRTC transport layer.
