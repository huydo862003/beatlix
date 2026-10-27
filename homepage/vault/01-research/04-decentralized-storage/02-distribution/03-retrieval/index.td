---
_label: "Retrieval"
_icon: icon.folder
---

[[directory-index]]

Retrieval is how a client fetches content once a provider is found via the DHT. IPFS uses Bitswap, a block exchange protocol where peers request blocks by CID and respond to requests from others. A node can assemble a file from blocks fetched from multiple peers simultaneously, and verifies each block by rehashing it against the expected CID.

## References

- [IPFS Docs: Bitswap](https://docs.ipfs.tech/concepts/bitswap/)
- [Bitswap Specification](https://github.com/ipfs/specs/blob/main/BITSWAP.md)
- [IPFS Docs: How IPFS Works](https://docs.ipfs.tech/concepts/how-ipfs-works/)
