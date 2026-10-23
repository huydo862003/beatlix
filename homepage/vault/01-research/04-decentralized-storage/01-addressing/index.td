---
_label: "Addressing"
_icon: icon.folder
---

[[directory-index]]

Addressing is the question of how you name and locate a piece of data. In centralized systems, data is identified by where it lives (a URL, a database row ID). In decentralized systems, that breaks down because there is no single authority to ask.

## General Idea

- **Location addressing** (how the web works today): a URL points to a specific server, so if the server moves or goes down, the link breaks. The data and its address are coupled to a location.
- **Content addressing**: data is identified by a cryptographic hash of its contents, not where it is stored. Anyone who has the data can serve it, and the recipient can verify integrity by hashing what they received.
  - A **CID** (Content Identifier) in IPFS is a content address. The same file always has the same CID, regardless of which peer serves it.
  - A **DHT** (Distributed Hash Table) is how peers find who has a given CID, spreading the lookup table across all peers so there is no central directory.

## References

- [IPFS Docs: Content Addressing](https://docs.ipfs.tech/concepts/content-addressing/)
- [IPFS Docs: CIDs](https://docs.ipfs.tech/concepts/content-addressing/#cids-content-identifiers)
- [libp2p Docs: DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
