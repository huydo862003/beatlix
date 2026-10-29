---
_label: "Key Exchange"
_icon: icon.message
---

How two users establish a shared secret for E2EE.

## Problem

E2EE requires both parties to share a secret key before they can exchange messages.

- **Online**: both peers are connected. A standard Diffie-Hellman exchange establishes the shared secret in real time.
- **Offline**: the recipient is not connected. X3DH (Signal) solves this by having the recipient pre-upload key bundles to the server. The sender fetches the bundle and derives a shared secret without the recipient being online.

## References

- [Signal >> X3DH](https://signal.org/docs/specifications/x3dh/) - async key exchange using pre-uploaded key bundles
- [libsignal](https://github.com/nickvdl/libsignal) - Signal Protocol implementation (Rust, JS, Java)
