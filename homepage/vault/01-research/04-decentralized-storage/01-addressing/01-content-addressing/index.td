---
_label: "Content Addressing"
_icon: icon.folder
---

[[directory-index]]

Content addressing identifies data by a cryptographic hash of its contents rather than by where it is stored. The hash is encoded into a **CID** (Content Identifier), which is self-describing: it encodes which hash function and data encoding were used, making it forward-compatible. Anyone holding the data can serve it, and the recipient can verify integrity by rehashing what they received.

## References

- [IPFS Docs: Content Addressing](https://docs.ipfs.tech/concepts/content-addressing/)
- [IPFS Docs: CIDs](https://docs.ipfs.tech/concepts/content-addressing/#cids-content-identifiers)
- [Multiformats: CID Specification](https://github.com/multiformats/cid)
- [Multiformats: Multihash](https://github.com/multiformats/multihash)
