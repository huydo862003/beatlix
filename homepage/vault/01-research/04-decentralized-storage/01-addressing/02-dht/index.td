---
_label: "DHT"
_icon: icon.folder
---

[[directory-index]]

A Distributed Hash Table (DHT) is the index that maps CIDs to the peers holding them, spread across all participating peers so there is no central directory.

IPFS uses Kademlia: every peer and CID is assigned an ID in the same key space, and each peer maintains a routing table of known peers organized by distance. Provider records (CID to peer mappings) are stored on the peers whose IDs are closest to the CID and must be re-announced periodically.

## References

- [libp2p Docs: Kademlia DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
- [Kademlia Paper (Maymounkov & Mazières, 2002)](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf)
- [IPFS Docs: How IPFS Works](https://docs.ipfs.tech/concepts/how-ipfs-works/)
