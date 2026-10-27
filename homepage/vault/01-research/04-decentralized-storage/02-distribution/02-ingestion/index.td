---
_label: "Ingestion"
_icon: icon.folder
---

[[directory-index]]

Ingestion is what happens when a file enters the network. The file is chunked into blocks, each block is hashed to produce a CID, and the blocks are assembled into a DAG (Directed Acyclic Graph) with a root CID representing the whole file. The node then announces provider records to the DHT so other peers can discover it holds those CIDs.

## References

- [IPFS Docs: How IPFS Works](https://docs.ipfs.tech/concepts/how-ipfs-works/)
- [IPFS Docs: UnixFS](https://docs.ipfs.tech/concepts/file-systems/#unix-file-system-unixfs)
- [IPFS Docs: Merkle DAG](https://docs.ipfs.tech/concepts/merkle-dag/)
