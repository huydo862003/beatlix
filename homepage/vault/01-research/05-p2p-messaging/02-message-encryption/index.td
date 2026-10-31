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

**Symmetric encryption (after KDF)**

- [Soatok >> Comparison of Symmetric Encryption Methods](https://soatok.blog/2020/07/12/comparison-of-symmetric-encryption-methods/) - which AEAD cipher to use, XChaCha20-Poly1305 vs AES-GCM
- [Soatok >> Why AES-GCM Sucks](https://soatok.blog/2020/05/13/why-aes-gcm-sucks/) - pitfalls of AES-GCM, why ChaCha20-Poly1305 is safer
- [Soatok >> Understanding Extended-Nonce Constructions](https://soatok.blog/2021/03/12/understanding-extended-nonce-constructions/) - why XChaCha20's 192-bit nonce avoids collision issues

**Key rotation / forward secrecy**

- [Soatok >> Cryptographic Wear-Out for Symmetric Encryption](https://soatok.blog/2020/12/24/cryptographic-wear-out-for-symmetric-encryption/) - message limits before a key must be rotated, the reason key rotation exists
- [Signal >> Double Ratchet](https://signal.org/docs/specifications/doubleratchet/) - per-message key rotation, forward secrecy
- [Matrix E2EE Spec](https://spec.matrix.org/latest/client-server-api/#end-to-end-encryption) - Megolm, optimized for group chats
- [libsignal](https://github.com/nickvdl/libsignal) - Signal Protocol implementation (Rust, JS, Java)
- [libolm](https://gitlab.matrix.org/matrix-org/olm) - Megolm implementation (C, JS)
