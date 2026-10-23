---
_label: "Relay Server"
_icon: icon.folder
---

[[directory-index]]

A relay server is a fallback for when a direct peer-to-peer connection cannot be established. It forwards raw traffic between peers without interpreting it. It is not a general message router or a media server.

> Media routing topology (mesh, SFU, MCU) is a separate concern covered in [Media Routing](../07-media-routing/index).

## General Idea

WebRTC always attempts a direct p2p connection first. A relay only comes into play when NAT traversal fails: the peer is behind a symmetric NAT or firewall that blocks all hole-punching attempts. In that case, a TURN server relays the encrypted RTP packets between the two peers.

- The relay never decrypts the media; DTLS/SRTP encryption is end-to-end between the peers.
- The relay is purely a packet forwarder with no knowledge of the call topology or content.
- TURN is defined in [RFC 8656](https://datatracker.ietf.org/doc/html/rfc8656) and is part of the ICE protocol stack covered in [Protocol Stack](../01-realtime-streaming-protocol-and-api/02-webrtc/04-protocol-stack).

For Beatlix, the relay also handles application-level concerns outside of WebRTC: forwarding sync commands (play, pause, seek) and buffering messages for offline peers via WebSocket.

## Key Design Concerns

- [**Performance**](01-performance/index) - connection throughput, message latency, scaling strategies
- [**Protocol**](02-protocol/index) - message framing, room routing, signaling protocol design

## References

- [Building Real-Time Applications with WebSockets in 2026](https://dev.to/vikrant_bagal_afae3e25ca7/building-real-time-applications-with-websockets-in-2026-architecture-scaling-and-production-48di)
- [Scaling WebSocket Connections: Single Server to Distributed](https://dev.to/young_gao/scaling-websocket-connections-from-single-server-to-distributed-architecture-1men)
- [WebSocket servers in JS: Node.js, Bun and Deno in 2026](https://lemire.me/blog/2026/10/10/websocket-servers-in-javascript-node-js-bun-and-deno-in-2026/)
- [strfry: high-performance Nostr relay in C++](https://github.com/hoytech/strfry)
- [rnostr: high-performance Nostr relay in Rust](https://github.com/rnostr/rnostr)
- [Advancements in Nostr Relays](https://opensats.org/blog/advancements-in-nostr-relays)
