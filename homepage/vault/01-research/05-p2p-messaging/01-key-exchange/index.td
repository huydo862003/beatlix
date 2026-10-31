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
  :::
- **ECDH (Elliptic Curve Diffie-Hellman)**: key exchange protocol using elliptic curve scalar multiplication.
- **X25519**: ECDH over Curve25519 (Montgomery form). The standard choice.
- **X448**: ECDH over Curve448. Larger key, higher security margin, slower.
- **X3DH**: Extended Triple Diffie-Hellman. Signal's protocol for offline key exchange.

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

## Offline Key Exchange: X3DH (Extended Triple Diffie-Hellman)

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
