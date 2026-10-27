---
_label: "Decentralized Storage"
_icon: icon.folder
---

[[directory-index]]

Decentralized storage addresses the question of where data lives when there is no central server. Instead of a single database, data is distributed across peers, nodes, or content-addressed networks.

::: warning
I figured this was too complicated for a simple webapp. And not everyone wants to join a network of peers and store data for each other. So we can just store data on their machine or their cloud and encrypts it with their key or something. **So this section is dropped**.
:::

## General Idea

Traditional storage puts data in a database you control. Removing that central server raises three problems:

- **Addressing**: without a fixed server, how do you name and locate data? Location-based URLs break when a node goes offline.
- **Distribution**: how does data spread across peers so no single node is the only copy?
- **Persistence**: how does data survive when peers go offline? If no peer is online and no server holds it, it is lost.

Every practical decentralized storage solution makes a tradeoff between how decentralized it is and how reliably data can be retrieved.

> This is a prerequisite for p2p messaging: before you can send a message without a central server, you need to know where it will be stored and how recipients will find it.

- [**Addressing**](01-addressing/index) - content addressing, CIDs, DHT
- [**Distribution**](02-distribution/index) - replication, CRDT, libp2p, Gun.js
- [**Persistence**](03-persistence/index) - pinning, IndexedDB, user-owned cloud, encrypted backup

## References

- [IPFS Documentation](https://docs.ipfs.tech/) - content addressing, CIDs, DHT, pinning, gateways
- [libp2p Documentation](https://libp2p.io/docs/) - the modular networking stack IPFS is built on
- [libp2p Specifications](https://github.com/libp2p/specs) - transport, peer discovery, pubsub, NAT traversal
- [Gun.js Documentation](https://gun.eco/docs/Awesome-GUN) - p2p graph database with browser support, CRDT-based sync
