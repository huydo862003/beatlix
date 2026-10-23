---
_label: "Realtime Streaming Protocol"
_icon: icon.folder
---

[[directory-index]]

How clients communicate in real time. Covers the two main transport options: WebSocket for server-mediated messaging and WebRTC for direct peer-to-peer connections.

- [**WebSocket**](01-websocket)
- [**WebRTC**](02-webrtc)

## General Idea

Real-time communication on the web requires a persistent connection between clients. The two dominant approaches solve different problems:

- **WebSocket** keeps a long-lived TCP connection open between a client and a server. The server mediates all communication. Simple to implement and works everywhere, but every message goes through your server.
- **WebRTC** establishes a direct connection between two browsers. Audio, video, and arbitrary data travel peer-to-peer without touching your server. More complex to set up (requires signaling, ICE negotiation, NAT traversal) but removes the server from the data path entirely.

For Beatlix, WebRTC is the primary transport for audio, video, and screen sharing. WebSocket is used for signaling (the coordination needed to establish WebRTC connections) and for any server-mediated coordination like sync messages.
