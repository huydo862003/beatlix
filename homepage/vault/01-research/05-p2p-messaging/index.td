---
_label: "P2P Messaging"
_icon: icon.folder
---

[[directory-index]]

P2P messaging addresses how messages are delivered between peers without routing through a central server. It builds on decentralized storage for persistence and adds delivery guarantees, presence, and end-to-end encryption.

## General Idea

Sending a message between two people seems simple, but a reliable messaging system needs to solve several hard problems:

- **Delivery**: what happens if the recipient is offline when you send? Someone has to hold the message until they reconnect.
- **Ordering**: messages must arrive in the right order, or at least be reassembleable in order.
- **Privacy**: who can read the message in transit or at rest? E2EE solves the content problem, but p2p adds complications:
  - You have less control over who holds the ciphertext.
  - Key distribution has no central directory.
  - Group key management requires coordination without an authority.
  - Forward secrecy requires stateful key exchange that must itself be persisted and synced.
- **History storage**: once delivered, where does the message live? Without a server keeping the log, history may be distributed across nodes, but the client must be able to locate only its own messages and be the only one who can read them.
  - Unlike general decentralized storage, a message log is ordered and append-only.
  - Sync is incremental: you only fetch what you missed, not the full log.

In a centralized system (Discord, Slack), a server handles all of this. In a p2p system, each of these problems is solved separately.

> See [Decentralized Storage](../04-decentralized-storage/index) for the storage layer this depends on.

- [**Delivery**](01-delivery/index) - WebRTC data channels, relays, federation
- [**History & Sync**](02-history-sync/index) - homeserver storage, p2p sync, user-owned cloud, encrypted backup

## References

- [RTCDataChannel - MDN](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel) - browser p2p data channels, cross-ref [WebRTC](../01-realtime-streaming-protocol-and-api/02-webrtc/05-webrtc-web-api)
- [W3C WebRTC Specification](https://www.w3.org/TR/webrtc/) - RFC8831 defines the data channel wire protocol
- [Matrix Specification](https://matrix.org/docs/spec/) - federated protocol with E2EE
- [Introducing P2P Matrix](https://matrix.org/blog/2020/06/02/introducing-p2p-matrix/) - browser-side storage via IndexedDB, no homeserver
- [Nostr Protocol](https://github.com/nostr-protocol/nostr) - relay-based, keypair identity, NIP specifications
