---
_label: "Replication"
_icon: icon.folder
---

[[directory-index]]

Replication is how content survives beyond the node that originally uploaded it. In [IPFS](../../00-general-concepts/01-ipfs/index), there is no automatic replication: if the uploader goes offline and no other node has pinned the content, it becomes unavailable. Peers must explicitly pin CIDs to keep them. Pinning services (Pinata, web3.storage) act as persistent nodes that pin content on behalf of users, providing availability without running a local daemon.

## References

- [IPFS Docs: Persistence and Pinning](https://docs.ipfs.tech/concepts/persistence/)
- [IPFS Docs: Pin Files](https://docs.ipfs.tech/how-to/pin-files/)
- [Pinata](https://www.pinata.cloud/)
- [web3.storage](https://web3.storage/)
