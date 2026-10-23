---
_label: "Delivery"
_icon: icon.folder
---

[[directory-index]]

Delivery is the question of how a message gets from the sender to the recipient when there is no central server to route it. The hard split is whether the recipient is online at the moment of sending. If they are, a direct p2p channel suffices. If they are not, someone must hold the message until they reconnect, and in a p2p system, deciding who that is and ensuring they are trustworthy is non-trivial.

## General Idea

- **Real-time**: WebRTC Data Channels send messages directly between browsers with no server involved. Only works while both peers are online. See [WebRTC](../../01-realtime-streaming-protocol-and-api/02-webrtc/05-webrtc-web-api).
- **Offline**: someone must hold the message until the recipient reconnects. Options include federated homeservers (Matrix) and volunteer relay networks (Nostr).

## References

- [MDN: RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)
- [Matrix Specification: Federation](https://spec.matrix.org/latest/server-server-api/)
- [Nostr NIP-01: Event and relay protocol](https://github.com/nostr-protocol/nostr/blob/master/nips/01.md)
