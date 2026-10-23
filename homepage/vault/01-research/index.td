---
_label: "Research"
_icon: icon.library
---

Research index for Beatlix. Three independent problems to study, each with its own technology surface.

## Music Sourcing

The app does not host music itself. It delegates to external providers for both discovery and playback. These are two separate concerns: finding a track and actually playing it. See ${fref("./03-music-vendor-api/index.td")}.

### Search

Users need to find music across one or more providers. The question is how each provider exposes its catalog and what you get back. See ${fref("./03-music-vendor-api/01-search/index.td")}.

**Problems to study**:

- How do you query a provider's catalog?
- What metadata is returned and is it consistent across providers?
- What breaks when a provider changes or a track becomes unavailable?

**Technologies**:

- YouTube Data API v3
- Spotify Web API
- SoundCloud API

### Playback

Once a track is found, it needs to play in the browser. There are two fundamentally different models here worth understanding: embedding the vendor's own player, or obtaining and streaming the audio yourself. Each has different tradeoffs in control, licensing, and what the browser is actually doing. See ${fref("./03-music-vendor-api/02-playback/index.td")}.

**Problems to study**:

- What are the two models for playing audio from a provider, and how do they differ?
- What level of playback control does each model give you?
- What are the constraints and requirements per provider?

**Technologies**:

- YouTube IFrame Player API
- Spotify Web Playback SDK
- SoundCloud Widget API

## Playback Sync

Playing the right track is not enough. Every client in a session must be at the same position at the same moment, even though they are on different machines with different network conditions. This is the hardest problem in the system. See ${fref("./01-realtime-streaming-protocol-and-api/index.td")}.

**Idea**: all clients in a session play the same track at the same position at the same moment.

**Problems to study**:

- Syncing:
  - How do you coordinate playback across clients who receive messages at different times?
  - How do you bring a new client up to the current session state?
- Drift:
  - What causes playback to fall out of sync over time?
  - How do you detect and recover from it without disrupting the experience?
- Session authority:
  - How is playback state owned and managed?
  - What happens when the owner disconnects?

**Technologies**:

- WebSockets (Socket.io) for real-time messaging between clients
- Clock synchronization techniques (how to agree on a shared notion of time across machines)
- WebRTC for peer-to-peer syncing

## Browser Audio Streaming

Beyond synced playback, a user may want to broadcast live audio directly: a mic, an instrument, or system output. This is a different problem from sync. Instead of coordinating when to play a shared source, one client is the source and must stream audio to all others in real time. See ${fref("./01-realtime-streaming-protocol-and-api/index.td")} and ${fref("./02-browser-media-api/index.td")}.

**Idea**: one user broadcasts live audio (mic, instrument, system audio) to others in the session.

**Problems to study**:

- Capture:
  - How does the browser access audio from different sources?
- Transport:
  - How do you send live audio from one browser to another over the internet?
  - What network conditions can block or degrade the stream?
  - How do you keep latency low enough for the stream to feel live?
- Topology:
  - How does the setup change when more than two people are in the session?

**Technologies**:

- Browser media capture APIs
- WebRTC for peer-to-peer audio transport
- Web Audio API for audio routing and processing
