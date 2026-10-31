---
_label: "Message Encryption"
_icon: icon.message
---

How each message is encrypted after the initial key exchange, with forward secrecy.

## Problem

Using a single shared key for all messages means: if that key is ever compromised, every past and future message is exposed.

After key exchange & KDF, both peers now obtain a shared known secret. This section concerns with how to use the shared secret to encrypt messages.

## Concepts

- **Symmetric encryption**: both sides use the same key to encrypt and decrypt.
- **Nonce** ("number used once"): a value that must be unique per encryption under the same key.
  It is not secret, sent alongside the ciphertext. Without it, encrypting the same plaintext twice produces identical ciphertext, leaking information about the conversation.
- **AEAD** (Authenticated Encryption with Associated Data): encrypts and produces an authentication tag in one operation. Tampering with the ciphertext causes decryption to fail. The "Associated Data" part lets you authenticate unencrypted metadata (e.g. headers, sequence numbers) alongside the ciphertext.
- **Unauthenticated encryption** (e.g. bare AES-CBC, AES-CTR): only scrambles data. An attacker can flip bits in the ciphertext without the recipient knowing, enabling attacks like padding oracles.
- **Nonce misuse**: accidentally reusing the same nonce with the same key. Some ciphers fail catastrophically (AES-GCM), others degrade gracefully ("misuse resistant," e.g. AES-GCM-SIV).
- **Forward secrecy**: compromising a key does not expose past messages. Achieved by rotating keys per message (Double Ratchet).

## Symmetric Encryption

Symmetric encryption refers to the fact that both sides use the same key to encrypt and decrypt a message.

### Methods

> Source: [Soatok >> Comparison of Symmetric Encryption Methods](https://soatok.blog/2020/07/12/comparison-of-symmetric-encryption-methods/)

| Tier | Method | Key | Nonce | Pros | Cons | Best use |
|------|--------|-----|-------|------|------|----------|
| S | **XChaCha20-Poly1305** | 256-bit | 192-bit | Large nonce makes random generation safe (collision after $2^{80}$ messages), constant-time in software | Not hardware accelerated | Default choice for most applications |
| S | **AES-GCM-SIV** | 128/256-bit | 96-bit | Nonce misuse resistant (reusing a nonce only leaks if same nonce + same plaintext), constant-time | ~30% slower than AES-GCM | When nonce misuse is a real risk |
| A | **AES-GCM** | 128/256-bit | 96-bit | Hardware accelerated (AES-NI), widely supported, fast | Small nonce (collision after $2^{32}$ messages with random nonces), catastrophic on nonce reuse | High-throughput servers with hardware AES support and careful nonce management |
| A | **ChaCha20-Poly1305** | 256-bit | 96-bit | Constant-time in software, no hardware dependency | Smaller nonce than XChaCha20 variant | When XChaCha20 is unavailable |
| B | **AES-SIV** | 256-bit | varies | Nonce misuse resistant | Slower (relies on CBC-MAC), two-pass encryption | Legacy systems needing misuse resistance |
| F | AES-ECB, RC4, Blowfish, Salsa20 | - | - | - | Broken or obsolete | Never use |

All methods above tier F are **AEAD** (Authenticated Encryption with Associated Data).

- **Unauthenticated encryption** (e.g. bare AES-CBC, AES-CTR): only scrambles the data. An attacker can't read it, but can flip bits in the ciphertext without the recipient knowing. This enables attacks like padding oracles, where the attacker modifies ciphertext and learns plaintext from decryption errors.
- **Authenticated encryption** (AEAD): encrypts and produces a tag that proves the ciphertext hasn't been modified. Tampering causes decryption to fail. The "Associated Data" part lets you also authenticate unencrypted metadata (e.g. headers, message sequence numbers) alongside the ciphertext.

**Nonce misuse**: accidentally reusing the same nonce with the same key. Different ciphers fail differently:

- **AES-GCM**: catastrophic. The attacker can recover the authentication key, forge messages, and XOR plaintexts together.

  ::: details How AES-GCM nonce reuse breaks everything

  **How AES-GCM works**: AES is a block cipher (encrypts fixed 128-bit blocks). AES-GCM combines two parts:

  1. **Encryption (CTR mode)**: generates a keystream from (key, nonce, counter=0, 1, 2, ...) and XORs it with the plaintext. This turns AES into a stream cipher.
  2. **Authentication (GHASH)**: hashes all ciphertext blocks ($B_1, ..., B_n$) into a tag using a secret hash key $H$: $\text{tag} = (B_1 \cdot H^n + \cdots + B_n \cdot H) \oplus \text{mask}$

  Both the keystream and the mask are fully determined by (key, nonce). Same nonce = same keystream and same mask. This breaks both parts independently:

  **1. Content leaks**: two plaintexts $P_1$, $P_2$ encrypted with the same keystream:
  - $C_1 \oplus C_2 = P_1 \oplus P_2$ (keystream cancels, attacker gets XOR of plaintexts).

  **2. Auth key recoverable**: two tags computed with the same mask. For ciphertext blocks $A_i$ (message 1) and $B_i$ (message 2):

  $\text{tag}_1 \oplus \text{tag}_2 = (A_1 \oplus B_1) \cdot H^n + (A_2 \oplus B_2) \cdot H^{n-1} + \cdots + (A_n \oplus B_n) \cdot H$

  This works because GHASH operates in $GF(2^{128})$, where addition is XOR. $GF(2^{128})$ is built on $GF(2) = \{0, 1\}$ where $1 + 1 = 0$ (XOR). Elements of $GF(2^{128})$ are 128-bit strings, and addition is bitwise XOR. So XOR distributes over multiplication just like normal addition does (field axiom: distributivity).

  The mask cancels. The left side is known (attacker has both tags). The coefficients $(A_i \oplus B_i)$ are known (attacker has both ciphertexts). The only unknown is $H$.

  So given a polynomial equation & one unknown, it is solvable over $GF(2^{128})$. Once $H$ is known, the attacker can forge valid tags for arbitrary messages.

  :::
- **AES-GCM-SIV / AES-SIV**: "misuse resistant". Reusing a nonce only reveals whether the same plaintext was encrypted twice. No key recovery, no forgery.
- **XChaCha20-Poly1305**: avoids the problem entirely. The 192-bit nonce makes accidental collision astronomically unlikely with random generation ($2^{80}$ messages before 50% collision chance).

**Library**: [libsodium](https://doc.libsodium.org/) (or `sodium-plus` for JS) provides XChaCha20-Poly1305 out of the box.

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
