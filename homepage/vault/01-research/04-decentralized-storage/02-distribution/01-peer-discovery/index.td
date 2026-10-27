---
_label: "Peer Discovery"
_icon: icon.folder
---

[[directory-index]]

Peer discovery is how a node finds other peers to connect to when joining the network. IPFS uses bootstrap nodes as a known entry point, mDNS for local network discovery, and the DHT for wider network discovery. Once connected to a few peers, a node can expand its routing table by querying for peers closer to any given key.

## References

- [libp2p Docs: Peer Discovery](https://docs.libp2p.io/concepts/discovery-routing/overview/)
- [libp2p Docs: mDNS](https://docs.libp2p.io/concepts/discovery-routing/mdns/)
- [libp2p Docs: Kademlia DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
- [IPFS Docs: Bootstrap Nodes](https://docs.ipfs.tech/how-to/modify-bootstrap-list/)
