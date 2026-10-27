---
_label: "CID Lookup"
_icon: icon.folder
---

[[directory-index]]

CID lookup is the process of resolving a CID to a peer that holds the content by walking the DHT hop by hop. Each hop queries peers closer to the CID's key until the provider record is found, then the requesting peer connects directly to the provider. Kademlia guarantees convergence in O(log n) hops.

> How the content is fetched once the provider is found is covered in [Retrieval](../../02-distribution/03-retrieval/index).

## References

- [IPFS Docs: How IPFS Works](https://docs.ipfs.tech/concepts/how-ipfs-works/)
- [libp2p Docs: Kademlia DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
