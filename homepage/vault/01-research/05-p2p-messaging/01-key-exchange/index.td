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

- **Field**: A set with two operations (called "addition" and "multiplication", but they can be any operations) that satisfy the field axioms:

  - **Closure**: $a + b \in F$ and $a \cdot b \in F$ for all $a, b \in F$
  - **Associativity**: $(a + b) + c = a + (b + c)$ and $(a \cdot b) \cdot c = a \cdot (b \cdot c)$
  - **Commutativity**: $a + b = b + a$ and $a \cdot b = b \cdot a$
  - **Identity**: exists $0$ such that $a + 0 = a$, and exists $1$ ($1 \neq 0$) such that $a \cdot 1 = a$
  - **Inverses**: for every $a$, exists $-a$ such that $a + (-a) = 0$; for every $a \neq 0$, exists $a^{-1}$ such that $a \cdot a^{-1} = 1$
  - **Distributivity**: $a \cdot (b + c) = a \cdot b + a \cdot c$

  Real numbers $\mathbb{R}$ are a field. Cryptography uses **finite fields (Galois fields)** $GF(p)$ or $\mathbb{F}_p$: the integers $\{0, 1, ..., p-1\}$ with arithmetic modulo a prime $p$.

- **Group**: a set with one operation that satisfies the group axioms:

  - **Closure**: $a \cdot b \in G$ for all $a, b \in G$
  - **Associativity**: $(a \cdot b) \cdot c = a \cdot (b \cdot c)$
  - **Identity**: exists $e$ such that $a \cdot e = e \cdot a = a$
  - **Inverse**: for every $a$, exists $a^{-1}$ such that $a \cdot a^{-1} = e$

- **Elliptic curve**: a smooth curve defined by a cubic equation in two variables, over a field.
  It has a **natural group law**: any two points on the curve can be "added" to produce a third.
  It has a key property: computing $kP$ (scalar multiplication, i.e. $\underbrace{P + P + \cdots + P}_{k}$) is fast ($O(\log k)$ via double-and-add), but recovering $k$ from $P$ and $kP$ is computationally infeasible (the **elliptic curve discrete log problem**).
  This one-way trapdoor is what makes elliptic curves useful for cryptography. Several canonical forms:

  - Weierstrass ($y^2 = x^3 + ax + b$)
  - Montgomery ($By^2 = x^3 + Ax^2 + x$)
  - Edwards ($x^2 + y^2 = 1 + dx^2y^2$)

  In cryptography, the curve is defined over $\mathbb{F}_p$ (a Galois field): coordinates $x, y \in \{0, 1, ..., p-1\}$ and all arithmetic in the equation is modulo $p$. This makes the number of points finite.

::: details How point addition works
**$P + Q$** (distinct points): draw a line through $P$ and $Q$, it intersects the curve at a third point $R$, reflect $R$ over the x-axis.
**$P + P$** (doubling): draw the tangent at $P$, it intersects at a second point $R$, reflect over the x-axis.
**Identity**: a "point at infinity" $\mathcal{O}$ such that $P + \mathcal{O} = P$.

Why reflect?

Without it, define $P +' Q$ = the third intersection point directly to be the point addition operation.

For the curve to be a group, there must be an identity point $e$ such that $P +' e = P$ for all $P$. That means the line through $P$ and $e$ intersects the curve at $P$, $e$, and $P$ again (multiplicity 2 at $P$), so the line is tangent to the curve at $P$. This must hold for every $P$ on the curve, meaning every line through $e$ is tangent to the curve. But the tangency condition reduces to a polynomial system, which by Bezout's theorem has only finitely many solutions. Contradiction: no such universal identity $e$ can exist.

With reflection: take the point at infinity $\mathcal{O}$ as identity. The line through $P$ and $\mathcal{O}$ is vertical, hits the curve at $(x_P, -y_P)$. Reflect -> $(x_P, y_P) = P$. So $P + \mathcal{O} = P$ for all $P$. The reflection is what makes a universal identity possible.

> See [Andrea Corbellini >> Elliptic Curve Cryptography: a gentle introduction](https://andrea.corbellini.name/2015/05/17/elliptic-curve-cryptography-a-gentle-introduction/) for visual interactive examples of point addition, and [Wolfram MathWorld >> Elliptic Curve Group Law](https://mathworld.wolfram.com/EllipticCurveGroupLaw.html) for the formal definition.
:::

::: details Why this operation?
It is not an arbitrary choice. A line intersects a cubic curve at exactly 3 points ([Bezout's theorem](https://en.wikipedia.org/wiki/B%C3%A9zout%27s_theorem)), so given any two points there is always a unique third. Reflecting gives closure and inverses for free. The resulting operation satisfies the group axioms (associativity is the hard part, proven via the [Cayley-Bacharach theorem](https://en.wikipedia.org/wiki/Cayley%E2%80%93Bacharach_theorem)).
:::

::: details Why cubic curves?
Degree-1 (lines) and degree-2 (conics) don't produce a group this way. Degree-3 is the simplest where the "3 intersection points" property gives the right structure. See [Conics: a Poor Man's Elliptic Curves](https://arxiv.org/pdf/math/0311306) for why conics fall short.
:::

::: details Why $y^2 = ...$ and not $y = ...$?
$y = x^3 + ax + b$ is also cubic and Bezout still applies, but it doesn't work:

- **No symmetry, no inverses**. $y^2$ makes the curve symmetric about the x-axis: if $(x, y)$ is on the curve, so is $(x, -y)$. This reflection defines inverses ($-P$ is the reflection of $P$). Without $y^2$, there is no natural inverse.
- **Too simple**. $y = x^3 + ax + b$ is parameterizable by a single variable, making it a rational curve (genus 0). The discrete log on rational curves is easy to solve. The $y^2$ term makes the curve genus 1 (non-rational), which is what makes the discrete log hard. See [MIT 18.783 Elliptic Curves, Lecture 1](https://math.mit.edu/classes/18.783/2025/LectureSlides1.pdf) for the genus distinction.
:::

- **Scalar multiplication**: $kP = \underbrace{P + P + \cdots + P}_{k}$ (point addition applied $k$ times). Computed efficiently in $O(\log k)$ via double-and-add.
- **Cyclic group**: a group where every element is produced by repeatedly applying the operation to a single element (the generator). If the generator is $G$ and the order is $n$, the group is $\{\mathcal{O}, G, 2G, 3G, ..., (n-1)G\}$ where $nG = \mathcal{O}$ (wraps back to identity).
- **Generator $G$**: a specific point on the curve that generates a cyclic group of order $n$. Computing $kG$ (scalar multiplication) is fast, but recovering $k$ from $kG$ is computationally infeasible (the elliptic curve discrete log problem).
- **Key derivation (KDF)**: a function that takes a raw shared secret and derives a proper encryption key.
  ::: details How KDF works
  The raw ECDH output is a point $(x, y)$ on the curve, not a uniform random bitstring. The coordinates satisfy the curve equation, so they are correlated, not all bitstrings are valid x-coordinates (only about half of field elements have a corresponding point), and the distribution is not uniform. An encryption key (e.g. AES-256) must be indistinguishable from a uniform random bitstring. A KDF (e.g. HKDF) extracts the entropy from the curve point and produces a uniform key of the right length. HKDF works in two steps:

  1. **Extract**: takes the raw input (the curve point's x-coordinate) and a salt, runs HMAC to produce a pseudorandom key.
  2. **Expand**: takes that key and an `info` string (context, e.g. "beatlix-chat-v1"), runs HMAC iteratively to produce the desired number of output bytes (e.g. 32 bytes for AES-256).

  Salt, info, and output length are public, fixed constants hard-coded into the protocol. The security comes from the shared secret, not the KDF parameters.

  There is another reason to use a KDF: since scalar multiplication is commutative, two unrelated pairs of participants could arrive at the same shared secret (for the same reason that $3 \times 8 = 4 \times 6$). A proper KDF hashes the ECDH output together with both participants' public keys, guaranteeing the derived session key is unique to this specific pair.
  :::
- **ECDH (Elliptic Curve Diffie-Hellman)**: key exchange protocol using elliptic curve scalar multiplication.
- **Curve25519**: an elliptic curve designed by Daniel J. Bernstein. It can be represented in Montgomery form ($By^2 = x^3 + Ax^2 + x$ with $A = 486662$, $B = 1$, $p = 2^{255} - 19$) or the birationally equivalent Edwards form. Both representations use the same underlying curve but serve different purposes:

  - **X25519**: ECDH over Curve25519 (Montgomery form).
    - Used for key exchange.
  - **Ed25519**: digital signature scheme over Curve25519 (Edwards form).
    - Used for signing/verifying (proving identity).

  Keys can be converted between the two via libsodium.

- **X448**: ECDH over Curve448. Larger key, higher security margin, slower.
- **X3DH**: Extended Triple Diffie-Hellman. Signal's protocol for offline key exchange.
- **Key bundle**: the set of public keys a recipient pre-uploads to a server so others can initiate encrypted conversations while the recipient is offline. It contains an identity key ($IK$), a signed pre-key ($SPK$) with its signature, and a batch of one-time pre-keys ($OPK_1, OPK_2, ...$). See [X3DH](#offline-key-exchange-x3dh-extended-triple-diffie-hellman).

## Online Key Exchange: ECDH Key Exchange

> Link: https://soatok.blog/2020/04/21/elliptic-curve-diffie-hellman-for-humans-and-furries/ (This is supposed to be an informal post)

The scenario: You need to
  - Establish data encryption between two peers over an untrusted medium (i.e. the Internet).
  - The two peers have an authenticated low-bandwidth channel but that channel isn't encrypted.

::: details Why these constraints?
- **Public**: if the side channel were private, the problem would already be solved. The whole point is to bootstrap encryption without a pre-existing secure channel.
- **Authenticated**: without authentication, a MITM can substitute their own key and silently relay messages. Authentication is the one property the side channel must provide.
  > It must be a channel where authenticity is provable but privacy is not required: e.g. a blockchain, a public key server with a known fingerprint, or a certificate signed by a trusted CA. Public and verifiable, not secret.
- **Low-bandwidth**: requiring a high-bandwidth side channel would defeat the purpose. The construction must work with the minimal out-of-band surface available (e.g. a QR code, a PIN).
:::

> A useful mental model: think of the authenticated channel as a blockchain. It is public, verifiable, and can carry a few bytes, but everything written to it is visible to anyone. The actual channel implementation does not matter for this thought experiment.

::: note
This used to be an unsolved problem in mathmaetics & cryptography before 1970.

Whitfeld Diffie, Martin Hellman & Ralph Merkle published the **"original" Diffie-Helleman protocol** & invented **asymmetric cryptography**.

Modern cryptography used the **Elliptic Curve variant of the Diffie-Hellman protocol** (ECDH).
:::

### Elliptic Curve Diffie-Hellman

Both peers agree on:

- An elliptic curve.
- A generator point $G$ of order $n$.

> In practice, nobody picks their own curve.
> They use a named standard like **Curve25519**, published in [RFC 7748](https://datatracker.ietf.org/doc/html/rfc7748):
> In Montgomery form: $By^2 = x^3 + Ax^2 + x$ over Galois fielf $p$, with $p = 2^{255} - 19$, $A = 486662$, $B = 1$, plus a fixed $G$ and $n$). Both peers just say "X25519" and all parameters are determined.
> These parameters are public, preferably hard-coded. When they are not, you get [CVE-2020-0601](https://nvd.nist.gov/vuln/detail/CVE-2020-0601).

::: details CVE-2020-0601 ("CurveBall")
Windows CryptoAPI (Windows 10, Server 2016/2019) accepted custom curve parameters from certificates instead of enforcing hard-coded ones.

The security guarantees came from given the parameters, it's hard to determine which **private key** produce a **public key**.

If the parameters can be specified, you change what secret key produces a given public key, so an attacker can craft parameters where they know the secret key for an existing trusted public key.

This allowed forging certificates that Windows accepted as signed by a legitimate CA. See [Kudelski Security >> CVE-2020-0601 explained with PoC](https://research.kudelskisecurity.com/2020/01/15/cve-2020-0601-the-chainoffools-attack-explained-with-poc/) and [Trail of Bits >> Exploiting the Windows CryptoAPI Vulnerability](https://blog.trailofbits.com/2020/01/16/exploiting-the-windows-cryptoapi-vulnerability/).
:::

Each participant generates a key pair:

1. Pick a random **secret key** $sk$ (an integer between $0$ and $n-1$).
2. Compute the **public key**: $pk = sk \times G$.
   > This is scalar multiplication: multiplying a number (the secret key) by a point (the generator). It is fast to compute but infeasible to reverse.

Note that both participants do this independently:

- Alice has $pk_A = sk_A \times G$
- Bob has $pk_B = sk_B \times G$

They exchange public keys over the authenticated channel. Then each multiplies their secret key by the other's public key:

- Alice computes $S_A = sk_A \times pk_B$
- Bob computes $S_B = sk_B \times pk_A$

Since scalar multiplication is commutative ($sk_A \times sk_B \times G = sk_B \times sk_A \times G$), both arrive at the same shared secret. An eavesdropper on the authenticated channel sees only $pk_A$ and $pk_B$ and cannot recover the shared secret or either secret key.

The raw shared secret is a point on the curve. Pass it through a **KDF** (e.g. HKDF) to derive the actual symmetric encryption key.

### Shared Secret Collision

Two unrelated pairs of participants can end up with the same shared secret, for the same reason $3 \times 8 = 4 \times 6$: different secret keys, same product. To prevent this, the KDF input should include both participants' public keys alongside the ECDH output, binding the derived key to this specific pair.

### Authenticating Public Keys

ECDH alone does not prove *who* you're talking to. Without authentication, an active attacker can substitute both public keys and sit in the middle, with neither party realizing they're talking to a middleman (MITM).

This is why the scenario requires an **authenticated** channel for exchanging public keys. Different systems solve this differently:

- **TLS (HTTPS)**: uses a chain of digital signatures from trusted root CAs. The server's ECDH public key is signed by the server's long-term key, which is in turn signed by a CA. The client trusts the CA's root certificate (pre-installed in the OS root store).
- **Signal / P2P messaging**: uses long-term identity keys. Each user has a stable identity key pair. Ephemeral ECDH public keys are signed by the identity key. Users verify each other's identity keys out-of-band (e.g. comparing "safety numbers").
- **SSH**: the server's public key is presented on first connection ("trust on first use") and the client remembers it for future connections.

### Invalid Curve Attacks

When Alice does ECDH, she computes $S = sk_A \times pk_B$. Her code just does scalar multiplication on whatever point it receives. If it doesn't verify the point is on the correct curve, the math still works, just on a different curve. The attacker exploits this:

1. The attacker poses as Bob and sends Alice a forged point $P'$ on a different curve with a very small group order (e.g. order 7).
2. Alice computes $S = sk_A \times P'$ and encrypts a message with a key derived from $S$. In a group of order 7, there are only 7 possible values for $S$. The attacker cannot compute $S$ via the normal ECDH path ($sk_B \times pk_A$) because $P'$ was not derived from $sk_B \times G$, so there is no valid $sk_B$ that produces the same shared secret. But with only 7 possibilities, the attacker brute-forces all of them against Alice's encrypted message. The one that decrypts correctly reveals $sk_A \mod 7$.
3. The attacker repeats with points on other small-order curves, learning $sk_A \mod 11$, $sk_A \mod 13$, etc.
4. Using the Chinese Remainder Theorem, the attacker combines these remainders to recover Alice's full secret key $sk_A$.

**Mitigation**: verify that the received point satisfies the chosen curve equation before using it.

**Modern approach**: only send a single coordinate plus a sign bit (point compression). X25519 goes further: it only uses the x-coordinate and is designed so that invalid points are handled safely by the curve arithmetic itself.

### Timing Side-channels

All operations (scalar multiplication, point addition, KDF) must run in **constant time**: the same number of steps regardless of the secret key's value. If execution time varies depending on the key bits, an attacker can measure timing differences (via network latency or other side-channels) and recover the secret key. This is one reason X25519 is preferred: Curve25519 was designed from the start to be easy to implement in constant time.

## Offline Key Exchange: X3DH (Extended Triple Diffie-Hellman)

> Link: https://soatok.blog/2020/11/14/going-bark-a-furrys-guide-to-end-to-end-encryption/

The problem: the recipient is offline. You can't do real-time ECDH because there's no one on the other end to generate an ephemeral key.

X3DH solves this by having the recipient **pre-upload a key bundle** to a server before going offline. A key bundle is the set of public keys packaged together that the server hands out to anyone who wants to start a conversation with this recipient.

### Key Types

X3DH uses four types of keys, each with a different lifetime and purpose:

- **Identity Key (IK)**: a **long-term Ed25519 signing keypair** that *represents the user's identity*, converted to **X25519** for *DH operations*.

  - It is used to:
    1. Sign key bundles (proving they came from this user).
    2. Bind the user's identity into the DH operations.
  - It is generated once & never rotated.

- **Signed Pre-Key (SPK)**: a **medium-term X25519 key-agreement keypair**, signed by **the identity key** and **rotated periodically** (e.g. weekly).

  - Always available. There is exactly one at any time. Every sender uses it in the handshake.
  - Because it is reused across all conversations between rotations, compromising it would break every session that relied solely on it.

- **One-Time Pre-Key (OPK)**: **disposable X25519 key-agreement keypairs**, _consumed one per session and deleted after use_.

  - Limited supply (e.g. 100). Each sender takes one from the server and it's gone.
  - Adds per-session uniqueness on top of the SPK: even if the SPK is compromised, past sessions that used a unique OPK remain safe.
  - When OPKs run out, the handshake still works, just without this extra layer of forward secrecy.

- **Ephemeral Key (EK)**: a **temporary X25519 key-agreement keypair** that the sender generates _fresh for each conversation_. It provides forward secrecy on the sender's side: even if the sender's identity key is later compromised, past conversations remain safe because the ephemeral private key was discarded.

### Flow

Alice wants to send Bob an encrypted message, but Bob is offline. Bob has previously uploaded his key bundle to a server. The server acts as a mailbox: it stores Bob's key bundle for anyone who wants to reach him, and holds encrypted messages until Bob comes back online.

The flow has three phases: registration, sending, and receiving.

#### 1. Registration (Bob, before going offline)

1. **Generate an identity keypair** ($IK_B$).
   - This is an **Ed25519 signing keypair**:
   - A private key that can sign data.
   - A public key that others use to verify signatures.
   - This represents Bob's long-term identity and is generated once.
2. **Generate a signed pre-key** ($SPK_B$).
   - This is an **X25519 key-agreement keypair** (an ECDH keypair: $sk$ is a random scalar, $pk = sk \times G$, the same as in the [online ECDH section](#elliptic-curve-diffie-hellman), just pre-uploaded instead of exchanged in real time).
   - Its purpose is deriving shared secrets, not signing.
3. **Generate a batch of one-time pre-keys** ($OPK_{B1}, OPK_{B2}, ...$), typically 100.
   - These are also **X25519 key-agreement** keypairs, one consumed per conversation.
   - Why separate from SPK? The SPK is medium-term (rotated weekly) and reused across multiple conversations until rotated. If the SPK is later compromised, every session that relied solely on it would be broken. OPKs add a unique, disposable element per session: even if the SPK is compromised, past conversations that used a unique OPK remain safe.
4. **Sign the bundle**: hash all public keys together with BLAKE2b (a fast cryptographic hash), then sign the hash with the identity key's private key. This proves the bundle came from Bob and hasn't been tampered with.
5. **Upload** the key bundle ($IK_B$, $SPK_B$ + signature, all OPK public keys) to the server. Bob keeps all private keys on his device.
6. Go offline. The server holds the bundle and hands it out to anyone who wants to reach Bob.

::: details Mapping to libsodium
| Step | Operation | libsodium function |
|------|-----------|-------------------|
| 1 | Generate Ed25519 signing keypair | `crypto_sign_keypair()` |
| 2, 3 | Generate X25519 key-agreement keypair | `crypto_box_keypair()` |
| 4 | Hash public keys with BLAKE2b | `crypto_generichash()` |
| 4 | Sign hash with Ed25519 private key | `crypto_sign_detached()` |
| DH | Convert Ed25519 keys to X25519 for DH | `crypto_sign_ed25519_sk_to_curve25519()` / `crypto_sign_ed25519_pk_to_curve25519()` |
:::

Bob should periodically come online to rotate $SPK_B$ and replenish OPKs when they run low.

#### 2. Sending (Alice, online)

1. Fetch Bob's pre-key bundle from the server: ($IK_B$, $SPK_B$, signature, and one $OPK_B$ if available).
2. Verify the bundle signature using $IK_B$ to confirm it came from Bob.
3. Generate a fresh ephemeral keypair $EK_A$.
4. Convert $IK_A$ from Ed25519 to X25519, then perform the DH operations:
   - $DH_1 = DH(IK_A, SPK_B)$ - binds sender's identity
   - $DH_2 = DH(EK_A, IK_B)$ - binds recipient's identity
   - $DH_3 = DH(EK_A, SPK_B)$ - forward secrecy via ephemeral key
   - $DH_4 = DH(EK_A, OPK_B)$ - per-session forward secrecy (omitted if no OPK available)
5. Derive shared secret: $SK = KDF(DH_1 \| DH_2 \| DH_3 \| DH_4)$
6. Encrypt the initial message with $SK$ and send it to the server along with:
   - $IK_A$ (so Bob knows who sent it)
   - $EK_A$ (so Bob can compute $DH_2$ and $DH_3$)
   - which $OPK_B$ was used (so Bob can look up the corresponding private key)

#### 3. Receiving (Bob, comes online later)

1. Receive the initial message with $IK_A$, $EK_A$, and the OPK identifier.
2. Look up the private keys for his $IK_B$, $SPK_B$, and the consumed $OPK_B$.
3. Convert $IK_B$ from Ed25519 to X25519, then perform the same DH operations from his side:
   - $DH_1 = DH(SPK_B, IK_A)$
   - $DH_2 = DH(IK_B, EK_A)$
   - $DH_3 = DH(SPK_B, EK_A)$
   - $DH_4 = DH(OPK_B, EK_A)$
4. Derive the same $SK = KDF(DH_1 \| DH_2 \| DH_3 \| DH_4)$ and decrypt.
5. Delete the consumed OPK's private key.

### Why 3 (or 4) DH operations?

A single ECDH would only establish a shared secret without proving identity. Each DH serves a purpose:

- $DH_1$ ($IK_A$, $SPK_B$): proves Alice's identity to Bob
- $DH_2$ ($EK_A$, $IK_B$): proves Bob's identity to Alice
- $DH_3$ ($EK_A$, $SPK_B$): provides forward secrecy (ephemeral + medium-term)
- $DH_4$ ($EK_A$, $OPK_B$): per-session forward secrecy, ensures each session is unique even if $SPK_B$ is later compromised

### Implementation Notes

- Identity keys are Ed25519 (for signing), converted to X25519 (for DH) via libsodium's `crypto_sign_ed25519_sk_to_curve25519` / `crypto_sign_ed25519_pk_to_curve25519`. Some cryptographers distrust this birational equivalence conversion, though no vulnerability has been demonstrated.
- The pre-key bundle is signed as a whole: a BLAKE2b hash of all concatenated public keys, with a detached Ed25519 signature over that hash.
- OPKs are consumed atomically: the server deletes them after handing them out. When OPKs run out, $DH_4$ is simply omitted. The protocol still works with 3 DH operations, but without per-session forward secrecy.
- SPKs should be rotated periodically (e.g. weekly). The previous SPK's private key may be kept briefly to handle delayed messages.

**Library**: [rawr-x3dh](https://github.com/soatok/rawr-x3dh) - Soatok's TypeScript X3DH implementation built on libsodium.

### Deniability

X3DH provides **deniability**: after a conversation, neither party can prove to a third party that the other person participated. The DH shared secret could have been computed by anyone who knows the public keys, so there is no cryptographic evidence tying a specific person to a message.

This is a deliberate contrast with digital signatures, which are proof that the signer authored a message. X3DH authenticates the exchange (both parties know who they're talking to) without creating non-repudiable evidence.

This matters for sensitive communications: even if messages leak, there is no mathematical proof of who said what.

> See [Soatok >> A Brief Introduction to Deniability](https://soatok.blog/2020/11/04/a-brief-introduction-to-deniability/) for a deeper treatment.

### After X3DH

X3DH is only used for the initial handshake. Using it for every message would be inefficient and unnecessary. After deriving $SK$, the protocol hands off to a **Double Ratchet**:

1. $SK$ seeds a **symmetric-key ratchet**: each message derives a new key from the previous one, so compromising one message key does not expose past or future messages.
2. A **DH ratchet** periodically introduces new ECDH exchanges to refresh the key material entirely.

This is covered in [Message Encryption](../02-message-encryption/index).

## E2EE

See [E2EE](../04-e2ee/index) for how key exchange fits into the full E2EE design.

## References

**Online key exchange: ECDH (X25519)**

- [Soatok >> Elliptic Curve Diffie-Hellman for Humans and Furries](https://soatok.blog/2020/04/21/elliptic-curve-diffie-hellman-for-humans-and-furries/) - ECC fundamentals, how ECDH works, why X25519 over P-256, common mistakes
- [Practical Cryptography for Developers >> ECDH Key Exchange](https://cryptobook.nakov.com/asymmetric-key-ciphers/ecdh-key-exchange) - walkthrough with code examples and best practices
- [ECCHacks (DJB & Tanja Lange)](https://cr.yp.to/talks/2014.12.27/slides-dan+tanja-20141227-a4.pdf) - gentle intro to ECC from the creators of Curve25519
- [RFC 7748: Elliptic Curves for Security](https://datatracker.ietf.org/doc/html/rfc7748) - X25519 and X448 specification
- [RFC 5869: HKDF](https://datatracker.ietf.org/doc/html/rfc5869) - HMAC-based key derivation function
- [Noise Protocol Framework](https://noiseprotocol.org/noise.html) - pattern-based handshake protocols built on ECDH, covers authenticated variants

**Offline key exchange: X3DH**

- [Signal >> X3DH](https://signal.org/docs/specifications/x3dh/) - async key exchange via pre-uploaded key bundles
- [Soatok >> Going Bark: A Furry's Guide to End-to-End Encryption](https://soatok.blog/2020/11/14/going-bark-a-furrys-guide-to-end-to-end-encryption/) - X3DH walkthrough with libsodium implementation
- [rawr-x3dh](https://github.com/soatok/rawr-x3dh) - Soatok's TypeScript X3DH implementation built on libsodium
- [Soatok >> A Brief Introduction to Deniability](https://soatok.blog/2020/11/04/a-brief-introduction-to-deniability/) - why X3DH provides deniability
- [Soatok >> Reviewing Signal's Cryptography, Part 3](https://soatok.blog/signal-crypto-review-2025-part-3/) - deeper review of Signal's X3DH implementation
