---
_label: "Addressing"
_icon: icon.folder
---

[[directory-index]]

Addressing is the question of how you name and locate a piece of data. In centralized systems, data is identified by where it lives (a URL, a database row ID). In decentralized systems, that breaks down because there is no single authority to ask.

## General Idea

In centralized settings, **location addressing** is often used (how the web works today):
  - A URL points to a specific server, so if the server moves or goes down, the link breaks.
  - The data and its address are coupled to a location.

In decentralized settings, **content addressing**: data is identified by a cryptographic hash of its contents, not where it is stored. Anyone who has the data can serve it, and the recipient can verify integrity by hashing what they received.
  - A **CID** (Content Identifier) in [IPFS](../00-general-concepts/01-ipfs/index) is a content address. The same file always has the same CID, regardless of which peer serves it.
  - A **DHT** (Distributed Hash Table) is how peers find who has a given CID, spreading the lookup table across all peers so there is no central directory.

> Knowing what a DHT is raises further questions:
> - How does a node join the DHT, and how does the DHT track which peers are online? See [Peer Discovery](../02-distribution/01-peer-discovery/index).
> - How does a file get uploaded into the network in the first place, and what happens at that moment? See [Ingestion](../02-distribution/02-ingestion/index).
> - Given a CID, how does the network locate which peer holds it without a central index? See [CID Lookup](03-lookup/index).
> - How does a client request and retrieve the file once the peer is found? See [Retrieval](../02-distribution/03-retrieval/index).
> - When a file is uploaded, it needs to be replicated so it survives if the uploader goes offline. How do other peers accept and store replicas, and what motivates them to do so? See [Replication](../02-distribution/04-replication/index).

## References

- [IPFS Docs: Content Addressing](https://docs.ipfs.tech/concepts/content-addressing/)
- [IPFS Docs: CIDs](https://docs.ipfs.tech/concepts/content-addressing/#cids-content-identifiers)
- [libp2p Docs: DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
