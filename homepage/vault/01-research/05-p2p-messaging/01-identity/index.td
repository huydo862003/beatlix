---
_label: "Identity"
_icon: icon.folder
---

[[directory-index]]

Identity is the question of how peers know who they are talking to. Without a central authority to assign and verify usernames, anyone could claim to be anyone, making messages untrustworthy. The problem has two parts: how is an identity created, and how does a recipient verify a message actually came from that identity.

## General Idea

- **Server-issued identity (Federation)**: a server assigns your identity (`@user:homeserver.com`) and vouches for you. Matrix uses this model.
  - Trust assumption: you trust the server not to impersonate you.
  - Failure mode: server down means your identity is inaccessible.
- **Cryptographic identity (Self-sovereign)**: you generate a local keypair and your public key is your identity, with no server involved. Nostr uses this model.
  - Verification: anyone can check a message signature against your public key.
  - Failure mode: losing your private key means losing your identity with no recovery path.

## References

- [Matrix Specification: Identity](https://spec.matrix.org/latest/client-server-api/#user-identifiers)
- [Nostr Protocol: keypairs and event signing](https://github.com/nostr-protocol/nostr/blob/master/nips/01.md)
- [W3C DID (Decentralized Identifiers) Specification](https://www.w3.org/TR/did-core/)
