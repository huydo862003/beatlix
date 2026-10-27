---
_label: "Distribution"
_icon: icon.folder
---

[[directory-index]]

Distribution is the question of how data spreads and stays consistent across peers. Once you know how to address data, you need a mechanism to replicate it and resolve conflicts when two peers write different values.

## General Idea

In a centralized system, a single database is the source of truth. In a decentralized system, multiple peers can write simultaneously, so you need rules for merging divergent state.

- **Replication**: each peer keeps a copy of the data. When a peer comes online, it syncs with others to catch up on missed writes.
- **CRDT** (Conflict-free Replicated Data Type): a data structure designed so that concurrent writes from different peers can always be merged without conflicts. Common strategies include last-write-wins (LWW) and grow-only sets.
- **libp2p**: the modular networking stack underlying [IPFS](../00-general-concepts/01-ipfs/index), providing transport, peer discovery, pubsub, and stream multiplexing. It can be used independently of IPFS.
- **Gun.js**: a p2p graph database built on CRDTs. Each peer stores the graph locally and syncs changes to all connected peers in real time.

- [**Peer Discovery**](01-peer-discovery/index) - bootstrap nodes, mDNS, DHT-based discovery
- [**Ingestion**](02-ingestion/index) - chunking, CID generation, DAG assembly, provider announcement
- [**Retrieval**](03-retrieval/index) - Bitswap, block exchange, multi-peer fetching
- [**Replication**](04-replication/index) - pinning, pinning services, availability guarantees

## References

- [libp2p Documentation](https://libp2p.io/docs/)
- [libp2p Specifications](https://github.com/libp2p/specs)
- [Gun.js Documentation](https://gun.eco/docs/Awesome-GUN)
- [Gun.js: CRDT explained](https://gun.eco/docs/Conflict-Resolution)
