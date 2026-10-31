---
_label: "Message Encryption"
_icon: icon.message
---

How each message is encrypted after the initial key exchange, with forward secrecy.

## Problem

Using a single shared key for all messages means: if that key is ever compromised, every past and future message is exposed.

## E2EE

See [E2EE](../04-e2ee/index) for how message encryption fits into the full E2EE design.

## References

- [Signal >> Double Ratchet](https://signal.org/docs/specifications/doubleratchet/) - per-message key rotation, forward secrecy
- [Matrix E2EE Spec](https://spec.matrix.org/latest/client-server-api/#end-to-end-encryption) - Megolm, optimized for group chats
- [libsignal](https://github.com/nickvdl/libsignal) - Signal Protocol implementation (Rust, JS, Java)
- [libolm](https://gitlab.matrix.org/matrix-org/olm) - Megolm implementation (C, JS)
