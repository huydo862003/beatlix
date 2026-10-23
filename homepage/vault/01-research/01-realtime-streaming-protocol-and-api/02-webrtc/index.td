
WebRTC (Web Real-Time Communication) is a browser API and protocol stack that lets two browsers exchange audio, video, and arbitrary data directly, without routing through a server. It bundles ICE, STUN, TURN, SDP, DTLS, and SRTP into a single API.

It does not require special drivers, plugins, or intermediary servers, though relay servers may be needed for complex NAT configurations.

Combined with the ${fref("/01-research/02-browser-media-api/01-media-capture-and-streams-api.td")}, it enables:

- **Audio & video conferencing**: capture and stream media between peers.
- **Screen sharing**: capture and stream screen content to remote peers.
- **File and data exchange**: transfer arbitrary data via `RTCDataChannel` without a server.
- **Identity management**: associate a third-party identity provider with a connection so the remote peer can cryptographically verify your identity during the handshake.
  > Defined via `RTCIdentityAssertion`, but never got real browser adoption and is largely a dead feature.
- **Legacy telephone integration**: communicate with traditional phone systems via DTMF (Dual-Tone Multi-Frequency) signaling.

## References

- MDN: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API
- WebRTC.org (official): https://webrtc.org/
- High Performance Browser Networking by Ilya Grigorik (WebRTC chapter): https://hpbn.co/webrtc/
- WebRTC for the Curious (deep dive into protocols): https://webrtcforthecurious.com/

Related media API: https://developer.mozilla.org/en-US/docs/Web/API/Media_Capture_and_Streams_API, covered in ${fref("/01-research/02-browser-media-api/01-media-capture-and-streams-api.td")}

## Media Routing

WebRTC's peer connection model works well for two parties. For group calls, the topology of how streams are arranged and forwarded becomes a separate concern.

> Covered in [Media Routing](../../../07-media-routing/index).
