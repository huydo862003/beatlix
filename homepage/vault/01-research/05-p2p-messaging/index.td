---
_label: "P2P Messaging"
_icon: icon.folder
---

[[directory-index]]

P2P messaging addresses how messages are delivered between peers without routing through a central server.

## General Idea

- **Online**: both peers are connected. Messages are sent directly via WebRTC Data Channels. See [WebRTC Web API](../01-realtime-streaming-protocol-and-api/02-webrtc/05-webrtc-web-api).
- **Offline**: recipient is not connected. Server buffers encrypted messages (E2EE) and delivers them when the recipient reconnects. The server only holds ciphertext, never plaintext.
- **History**: the server buffer already stores message history. On reconnect, the client fetches what it missed. History can also be backed up to the user's own cloud (e.g. Google Drive) for portability and user ownership.

- [**Key Exchange**](01-key-exchange/index) - establishing a shared secret between two peers
- [**Message Encryption**](02-message-encryption/index) - per-message key rotation with forward secrecy
- [**Backup / Device Migration**](03-backup-device-migration/index) - recovering keys and history on a new device
- [**E2EE**](04-e2ee/index) - how the pieces fit together

## References

- [RTCDataChannel - MDN](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel) - browser p2p data channels
- [Signal >> Documentation](https://signal.org/docs/) - E2EE protocol specs
- [libsignal](https://github.com/nickvdl/libsignal) - Signal Protocol implementation (Rust, JS, Java)
