---
_label: "Key Exchange"
_icon: icon.message
---

How two users establish a shared secret for E2EE.

## Problem

E2EE requires both parties to share a secret key before they can exchange messages.

- **Online**: both peers are connected. A standard Diffie-Hellman exchange establishes the shared secret in real time.
- **Offline**: the recipient is not connected. X3DH (Signal) solves this by having the recipient pre-upload key bundles to the server. The sender fetches the bundle and derives a shared secret without the recipient being online.

## Concepts

- Key derivation
- ECDH
- X25519
- X448
- X3DH

## Online Key Exchange: ECDH Key Exchange

## Offline Key Exchange: X3DH (Extended Triple Diffie-Hellman)

## References

**Online key exchange: ECDH (X25519)**

- [RFC 7748: Elliptic Curves for Security](https://datatracker.ietf.org/doc/html/rfc7748) - X25519 and X448 specification
- [RFC 5869: HKDF](https://datatracker.ietf.org/doc/html/rfc5869) - HMAC-based key derivation function
- [Noise Protocol Framework](https://noiseprotocol.org/noise.html) - pattern-based handshake protocols built on ECDH, covers authenticated variants

**Offline key exchange: X3DH**

- [Signal >> X3DH](https://signal.org/docs/specifications/x3dh/) - async key exchange via pre-uploaded key bundles
