---
_label: "IPFS (InterPlanetary File System)"
_icon: icon.folder
---

[[directory-index]]

IPFS is a **protocol specification** of a **set of protocol** for a decentralized file system built on **content addressing** and **peer to peer networking**.

It specifies how files are:
  - **Identified**
  - **Routed**
  - **Fetched**
  - **Uploaded**
  _across a network of peers_.

Local storage is not specified and is left to each implementation.

::: note
IPFS doesn't specifies how files are stored, only how files are identified, routed and fetched.
:::

It is composed of:
  - **CIDs** for content addressing.
  - **Kademlia DHT** for routing and peer/provider discovery.
  - **Bitswap** for block exchange and retrieval.
  - **UnixFS + DAG** for chunking and ingestion.

It can also mean:
  - IPFS spec implementations (see [Implementation Principles](#implementation-principles)).
  - An open and participatory decentralized network of IPFS nodes.

## References

- [IPFS Documentation](https://docs.ipfs.tech/)

## General Idea

IPFS is **a set of open protocols** for:
  - **Addressing**
  - **Routing**
  - **Transferring data on the web**

It:

- Assumes **data immutability** and uses **cryptographic hashing** for **content addressing**.
- Utilizes p2p networking for data transfer.

## What IPFS Solves

- **Verifiability**: content is identified by a cryptographic hash, so tampering is detectable.
- **Resilience**: no single point of failure. Data is available as long as at least one node holds it.
- **Centralization**: open, distributed, community-maintained network with no single controlling entity.
- **Performance**: content can be fetched from the nearest node holding it, reducing latency.
- **Link rot**: content is addressed by what it is, not where it is, so it remains reachable regardless of server availability.
- **Data sovereignty**: users store and access data on a decentralized network, with no intermediary controlling it.
- **Off-chain storage**: storing large files on a blockchain is expensive. Instead, store the file on IPFS and put its CID in the smart contract. Since the CID is a hash of the content, anyone can verify the file on IPFS matches what the contract points to.
- **Local-first software**: data can be stored and verified locally, then synced with other nodes when a connection is available.
- **Vendor lock-in**: content addressing decouples data from any specific provider or location. Storage can be moved without changing APIs or data management.

## What IPFS is Not

- **Not a storage provider**:
  - IPFS is a protocol.
  - Pinning services (e.g. Pinata, web3.storage) are storage providers built on top of IPFS.
- **Not a cloud service provider**:
  - IPFS can complement cloud infrastructure, but it is not a cloud service itself.

## Implementation Principles

Any software is considered an IPFS implementation if it adheres to the core principles below. Implementations may vary in language, subsystems, and supported specs. See [IPFS Docs: Implementations](https://docs.ipfs.tech/concepts/implementations/).

**Core principles** (required):

- Support addressability using CIDs.
- Any operation exposed to other IPFS nodes (fetching, advertising, indexing, etc.) must use CIDs as the identifier. The set of operations is open-ended.
- When fetching content by CID, hash the received bytes and confirm they match the CID. This may be skipped in trusted environments where verification already happened upstream.

**Recommended principles** (not strictly required):

- Assign CIDs to any resource another node might want to fetch. When in doubt, give it a CID.
- Give each logical data unit (file, directory, CBOR document, index branch) its own CID so nodes can fetch and verify individual parts independently.
- Split large content into chunks, each with its own CID in a DAG, so nodes can fetch and verify one chunk at a time without downloading everything first.
- Work over any transport (HTTP, libp2p, etc.). The choice of transport must not change what content a CID resolves to.

## Mechanisms and Subsystems

IPFS has three key responsibilities, each handled by dedicated subsystems. Its functionality also spans beyond these three.

| Purpose | Subsystems | Role |
|---|---|---|
| **Representing and organizing data** | CIDs, IPLD, UnixFS, MFS, DAG-CBOR, DAG-JSON, CAR files | Chunk files into blocks, hash each block into a CID & link blocks into a **Merkle DAG** (1) for independent verification |
| **Content routing** | Kademlia DHT, Delegated routing over HTTP, Bitswap, mDNS | Look up which peers hold a CID via distributed table, direct peer queries, or local network discovery |
| **Transferring data** | Bitswap, HTTP Gateways, Sneakernet, Graphsync | Exchange blocks peer-to-peer, serve over HTTP, or transfer offline via archive files |
| **Addressing** | Multiformats | Each CID, hash, and peer address carries a prefix that identifies the algorithm used (e.g. SHA-256). New algorithms get a new prefix; old values still decode correctly. |
| **Bridging IPFS and HTTP** | IPFS Gateways, **Pinning** (2) API Spec | Expose HTTP APIs for fetching content and requesting remote nodes to pin CIDs |
| **Peer-to-peer connectivity** | libp2p (TCP, QUIC, WebRTC, WebTransport) | Discover peers, establish connections, and multiplex over multiple transports |
| **Mutability and dynamic naming** | IPNS, DNSLink | CIDs are immutable: updating content produces a new CID. IPNS/DNSLink provide a stable name that can be re-pointed to the latest CID. |

Note:

- (1) Merkle DAG: a directed acyclic graph where each node is identified by the hash of its contents, and each node references its children by their hashes.
  - Changing any node changes its hash, which propagates up to the root, so the root hash alone can verify the entire structure.
  - A blockchain is a special case where each node has exactly one parent (a linear chain).
    -> A Merkle DAG generalizes this to a tree/graph where nodes can have multiple children and parents.
- (2) Pinning: by default, IPFS nodes cache fetched content but may garbage-collect it later. Pinning marks a CID as permanent on that node, preventing deletion.
  - You cannot force another peer to pin your content. Pinning is always voluntary.
  - Without pinning, content disappears once every node that cached it cleans up.
  - Pinning services (e.g. Pinata, web3.storage) are third-party nodes you pay to pin on your behalf.
  - IPFS has no built-in incentive for peers to store content they don't need. Filecoin adds economic incentives (pay tokens for guaranteed storage).

See [IPFS Docs: How IPFS Works](https://docs.ipfs.tech/concepts/how-ipfs-works/).

### Representing and Addressing Data

How data is structured and named in IPFS:

- A file is split into blocks by [UnixFS](#unixfs), which is built on [IPLD](#ipld-interplanetary-linked-data).
- Each block is assigned a **CID** computed from its **hash** and **codec** (1) via **Multiformats**.
- **IPLD** links the **blocks** into a **Merkle DAG**, so the whole file can be addressed and verified by a single root CID.

```d2
Root: "Root\nQmRoot..."
Int1: "Int1\nQmInt1..."
Int2: "Int2\nQmInt2..."
A: "Block A\nQmA..."
B: "Block B\nQmB..."
C: "Block C\nQmC..."
D: "Block D\nQmD..."

Root -> Int1
Root -> Int2
Int1 -> A
Int1 -> B
Int2 -> C
Int2 -> D
```

- For small files, the root links directly to the leaf blocks.
- For large files, IPFS builds a balanced tree with intermediate nodes so the root doesn't have to list every block.
- Any change to a block changes its CID, which propagates up through intermediates to the root.
- A node can verify or fetch a subtree (e.g. Int1 -> A, B) without downloading the whole file.

Notes:

- (1) Codec (coder-decoder): tells IPFS how to interpret the bytes in a block (e.g. raw bytes, DAG-CBOR, DAG-JSON, UnixFS). The codec identifier is embedded in the CID so any node knows how to decode the block.

#### CID (Content Identifier)

- A CID is:
  - A **unique identifier** for _a block of data_.
  - Computed from its **hash** and **codec** using [Multiformats](#multiformats-addressing).

In location-based systems (HTTP), a URL tells you where data lives, not what it is. If the server moves or changes the content, the link breaks or returns different data silently. A CID solves this by deriving the identifier from the content itself.

With a CID, the identifier is derived from the content itself:
  - Data can be fetched from any peer, not just a specific server.
  - Verify by recomputing the hash and comparing. Tampered or corrupted data produces a different CID.
  - The same content always has the same CID, enabling deduplication across the network.

#### IPLD (InterPlanetary Linked Data)

Blocks by themselves are just raw bytes. Without a common data model, every IPFS implementation would need custom logic to understand how blocks relate to each other (which block is a file, which is a directory, how they link). IPLD is that common data model.

- Identifies what a block is via its codec (raw bytes, DAG-CBOR, UnixFS, etc.).
- Links blocks to each other by CID, forming a Merkle DAG.
- Provides base operations on the DAG: structuring, serializing, and traversing content-addressed data.
- Can represent arbitrary data types: files, directories, CBOR objects, custom DAGs, etc.
- Standardized across all IPFS implementations: any node can read data produced by another, regardless of language or implementation. Designed to be upgradeable and backwards compatible.

##### Merkle DAG

IPLD links blocks into a graph structure. A flat list of blocks would work for simple files, but it does not scale and cannot represent hierarchical data like directories. A Merkle DAG solves both:

- A directed acyclic graph where each node is identified by the hash of its contents.
- Each node references its children by their CIDs, forming a verifiable chain from root to leaf.
- Changing any node changes its CID, which propagates up through all parent nodes to the root. Verifying the root CID verifies the entire structure.
- For large files, IPFS builds a balanced tree with intermediate nodes so the root does not list every block directly. This allows partial verification and fetching of subtrees.
- A blockchain is a special case where each node has exactly one parent (a linear chain). A Merkle DAG generalizes this to a tree/graph where nodes can have multiple children and parents.

```d2
Root: "Root\nQmRoot..."
Int1: "Int1\nQmInt1..."
Int2: "Int2\nQmInt2..."
A: "Block A\nQmA..."
B: "Block B\nQmB..."
C: "Block C\nQmC..."
D: "Block D\nQmD..."

Root -> Int1
Root -> Int2
Int1 -> A
Int1 -> B
Int2 -> C
Int2 -> D
```

##### UnixFS

UnixFS is a file system abstraction on top of IPLD. IPLD only knows about linked blocks; it has no concept of files, directories, or how to chunk large content. UnixFS defines the conventions for representing these on top of IPLD.

- Defines how files, directories, and symlinks are encoded as IPLD nodes.
- Automatically chunks large files into fixed-size blocks and links them into a Merkle DAG.
- The root CID of a UnixFS DAG represents the whole file or directory tree, and can be used to fetch or verify it.

##### MFS (Mutable File System)

UnixFS and IPLD are immutable: adding or changing a file produces a new root CID. Directly working with CIDs for every file operation is impractical for applications used to a traditional filesystem.

MFS provides a mutable filesystem interface on top of IPFS:

- Exposes familiar path-based operations (read, write, move, delete) while managing CID updates internally.
- Each write produces a new root CID under the hood, but the application only sees a file path.

##### DAG-CBOR / DAG-JSON

IPLD needs concrete encoding formats to serialize structured data into blocks. DAG-CBOR and DAG-JSON are two IPLD codecs for this:

- **DAG-CBOR**: encodes structured data (objects, maps, lists) as compact binary CBOR, with CID links embedded as a native type.
- **DAG-JSON**: the JSON equivalent, human-readable but larger. Useful for debugging and interoperability.

Both produce content-addressed blocks that can be linked into a Merkle DAG like any other IPLD node.

#### CAR Files

Moving collections of IPLD blocks between nodes requires a format that preserves the block graph. CAR (Content Addressable aRchive) files solve this:

- Serialized archives of IPLD blocks, similar to TAR files.
- Preserve the block graph so the receiver can reconstruct the full DAG.
- Used for import/export, offline transfer, and seeding content to pinning services.

### Content Routing

Content routing is how IPFS determines where to find a given CID on the network. A CID alone is not enough; the node needs the IP addresses and ports of peers that hold it.

#### Kademlia DHT

A CID tells you what content to fetch but not who has it. A central index would be a single point of failure. Kademlia solves this with a distributed index across all nodes in the network.

**Structure**:

- Every node is assigned a random 256-bit node ID when it joins. CIDs are also 256-bit hashes. Because they share the same number space, you can compute a distance between a node ID and a CID.
- Distance is measured by XOR: `distance = nodeID XOR cid`. This is purely mathematical, not geographic or based on network latency. It measures how many bits differ between two IDs:
  ```
  nodeID: 0110 1010
  cid:    0110 0011
  XOR:    0000 1001  = distance 9
  ```
  A smaller XOR result means the IDs share more leading bits, so they are "closer". The node with the smallest XOR distance to a CID is responsible for storing that CID's provider record. Two nodes on opposite sides of the world could be "distance 0" if their IDs happen to share all bits. XOR was chosen because:
  - Symmetric: `distance(A, B) == distance(B, A)`, so both nodes agree on how far apart they are.
  - Unidirectional: for any key, all lookups converge to the same set of nodes. Queries do not loop.
  - No coordination needed: every node computes the same distance independently.
  - Fast: XOR is a single CPU instruction.
- Each node maintains a routing table divided into k-buckets, one per distance range. Bucket 0 holds peers differing only in the last bit, bucket 1 in the second-to-last, and so on. Each bucket holds at most k=20 peers. This means a node knows many nearby peers and few distant ones, which is exactly what efficient routing requires.

The DHT separates two concerns: **routing** and **storage**.
  - **Routing (provider records)**: DHT-closest nodes store provider records for CIDs near their node ID. A provider record is a small pointer: `CID -> IP/port of the node that holds the content`. These DHT-closest nodes do not need to hold the content bytes themselves.
  - **Storage (content bytes)**: any node can pin any CID regardless of XOR distance. When a node pins a CID, it stores the content bytes locally and announces a provider record to the DHT nodes XOR-closest to that CID.
  - When a lookup resolves, the requesting node gets back a provider record pointing to the pinner, then connects directly to the pinner to fetch the content bytes.
  - If a lookup arrives for a CID a node does not have a provider record for, it replies with the peers in its routing table that are XOR-closer to that CID. This drives hop-by-hop convergence toward the node holding the provider record.
  - There is no enforcement: a node can ignore provider record announcements. IPFS is a cooperative protocol.

**Operations**:

- **Lookup**: to find who holds a CID, a node queries the peers in its routing table that are XOR-closest to the CID. Each hop replies with peers even closer to the target, converging in $O(\log n)$ hops.
- **Publish**: any node that has content (the original uploader or any node that pinned it) announces a provider record to the DHT nodes closest to the CID. A CID can have multiple providers. When a lookup resolves, it may return multiple provider records, and Bitswap can fetch from all of them in parallel.
- **Self-organizing**: nodes join and leave without breaking the table. The DHT repairs itself as peers come and go.
- Uses [libp2p](#libp2p-peer-to-peer-connectivity) to establish connectivity.

::: details What happens when a peer dies?
It depends on what the dead peer held:

**If it held only provider records (routing metadata)**:

- The DHT self-heals. Dead peers are evicted from k-buckets over time.
- The content provider periodically re-announces provider records (~12h), so new nearest nodes pick them up automatically.
- No content is lost, only routing entries, which are recovered automatically.

**If it held pinned content**:

- The content is gone from that node permanently.
- If another node also pinned it, that node still serves it and its provider record remains in the DHT.
- If no other node has it, the content is lost.

**If all providers for a CID die**:

- No more re-announcements. Provider records expire after ~24h.
- Content becomes undiscoverable via DHT even if some node still has cached copies, because cached nodes do not announce provider records and cannot be found via DHT lookup.
- Recovery is only possible if another node pinned it before all providers died and re-announces itself as a provider.

**Unpinning**:

- A node can unpin a CID at any time. Once unpinned, the blocks become eligible for garbage collection and the node stops re-announcing its provider record.
- If it was the last provider, the content becomes undiscoverable after the TTL expires.

**Cached copies are not enough**:

- Caching nodes do not publish themselves to the DHT as providers. Other nodes cannot discover them via lookup.
- Even if many nodes have blocks cached, the content is effectively lost from the network once all pinned providers go offline.

IPFS has no automatic recovery mechanism. Resilience relies entirely on redundancy through pinning.
:::

::: details Does IPFS replicate content?
IPFS has no built-in replication protocol. Copies arise organically:

- Every node that fetches a CID caches the blocks temporarily.
- Multiple nodes can pin the same CID independently.
- The DHT can hold provider records pointing to multiple peers for the same CID, and Bitswap can fetch from all of them in parallel.

There is no way to enforce a replication factor without something like Filecoin on top.
:::

::: details How does pinning relate to DHT?
**DHT**: routes lookups to a target node. It has no concept of pinning or storage. It only knows that a node announced itself as a provider for a CID.

**Pinning**: a node decides to permanently store the content bytes of a CID. When it does, it announces a provider record to the DHT so others can find it.

These two are connected only through the announcement. The DHT routes to a node that happens to have pinned the content. From the DHT's perspective, it is just routing to a provider. What that provider does internally (pin, cache, re-serve) is not its concern.
:::

#### Bitswap (for routing)

Bitswap is a message-based, peer-to-peer protocol for both routing and data transfer. DHT lookups take multiple hops and can be slow. Bitswap short-circuits this by querying already-connected peers directly:

- Asks directly connected peers if they hold requested CIDs, without traversing the DHT.
- Peers maintain wantlists: if a peer asks for a block and doesn't get it immediately, the request is held. When a peer receives that block later (from anyone), it forwards it to everyone that asked. The peer may also propagate the want to its own connected peers, effectively fetching on the requester's behalf.
- This is cooperative: peers are expected to serve and forward blocks, but there is no enforcement. Bitswap tracks a debt ratio per peer (how much you've sent vs. received) and deprioritizes peers that consistently take without giving.
- Uses [libp2p](#libp2p-peer-to-peer-connectivity) to establish connectivity.

#### mDNS

DHT and Bitswap require internet connectivity and bootstrap nodes. For local networks (e.g. offline or private deployments), mDNS provides peer discovery without any external coordination:

- Discovers IPFS nodes on the local network using multicast DNS.
- No internet connection or bootstrap nodes required.

#### Delegated Routing over HTTP

Not all nodes have the resources to run a full DHT implementation (e.g. browser nodes, lightweight clients). Delegated routing lets them offload this:

- Outsources routing queries to an external server via a standard HTTP API.
- The server searches the DHT on the node's behalf and returns provider records.
- Allows custom routing backends without changing the client implementation.

### Transferring Data

Once a peer holding the CID is found, data must be transferred. Some nodes already have the data, others want a copy.

#### Bitswap (for transfer)

Once a peer is found, blocks need to be exchanged efficiently. Bitswap handles direct block transfer between connected peers:

- Sends requested blocks directly from peer to peer without re-traversing the DHT.
- Peers maintain wantlists so blocks can be sent as soon as they become available.

#### HTTP Gateways

Most HTTP clients (browsers, curl, existing apps) cannot speak the IPFS protocol natively. HTTP Gateways bridge this gap:

- An IPFS node that also exposes an HTTP API, translating HTTP requests into IPFS fetches.
- Allows any HTTP client to access IPFS content without running a local node.

#### Sneakernet

In air-gapped or offline environments, no network transfer is possible. Sneakernet handles this edge case:

- Transfer CAR files between nodes via physical media (USB drive, hard disk) with no network connection.
- Content remains verifiable by CID on the receiving side, same as any other IPFS transfer.

#### Graphsync

Fetching a large DAG with Bitswap requires one round-trip per block. For large linked structures this is slow. Graphsync reduces this:

- Transfers an entire DAG subgraph in a single request by specifying a root CID and a selector.
- More efficient than Bitswap for large or deeply nested structures.

### Supporting Subsystems

Beyond the three core responsibilities, IPFS relies on additional subsystems:

#### Multiformats (Addressing)

Without Multiformats, every node must agree in advance on which algorithm to use. Switching algorithms requires upgrading every node at once or breaking compatibility with older data.

Multiformats fixes this by prefixing every value with a code that identifies what it is and how it was encoded:

- **multihash**: prefixes a hash with the algorithm used (e.g. SHA-256, SHA3, BLAKE2).
- **multicodec**: prefixes data with the format (e.g. DAG-CBOR, DAG-JSON, raw bytes).
- **multiaddr**: prefixes a network address with the protocol (e.g. `/ip4/1.2.3.4/tcp/4001`).
- **multibase**: prefixes an encoded string with the base encoding used (e.g. base58, base32).

A CID is built from multihash + multicodec. New algorithms get a new prefix code; old values still decode correctly without any coordination.

#### libp2p (Peer-to-peer Connectivity)

IPFS subsystems like Kademlia and Bitswap need to open connections to peers, but different environments support different transports (TCP on servers, WebRTC in browsers, QUIC for performance). Without an abstraction, each subsystem would need to handle transport differences itself.

libp2p is the modular networking stack IPFS is built on:

- Handles peer discovery, connection establishment, and multiplexing across transports.
- Supports TCP, QUIC, WebRTC, and WebTransport, allowing IPFS to run in browsers and servers alike.
- Used by Kademlia and Bitswap to establish connectivity.

#### IPFS HTTP Gateways and Pinning API Spec (Bridging IPFS and HTTP)

HTTP clients cannot speak IPFS natively, and not everyone can run a full IPFS node. These two specs bridge that gap:

- **IPFS HTTP Gateways**: an IPFS node that also exposes an HTTP API, allowing any HTTP client to fetch IPFS content without running a local node.
- **Pinning API Spec**: a standard HTTP API for requesting a remote node to pin a CID on your behalf. Pinning services (Pinata, web3.storage) implement this spec so clients can persist content without running their own node.

#### IPNS and DNSLink (Mutability and Dynamic Naming)

CIDs are immutable: updating a file produces a new CID. Sharing a raw CID means the link breaks as soon as the content is updated. These subsystems solve this by providing a stable, updatable name. Think of a CID like a git commit hash and IPNS like a branch name that you can move to the latest commit.

- **IPNS (InterPlanetary Naming System)**: a mutable pointer to a CID, signed by a keypair. The name stays stable while the pointer can be updated to a new CID.
- **DNSLink**: maps a DNS domain to a CID or IPNS name via a TXT record. Gives human-readable names to IPFS content using existing DNS infrastructure.
