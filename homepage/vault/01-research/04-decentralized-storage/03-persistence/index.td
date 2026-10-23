---
_label: "Persistence"
_icon: icon.folder
---

[[directory-index]]

Persistence is the question of how data survives: across sessions, across devices, and when peers go offline. Addressing and distribution tell you how to name and spread data, but neither guarantees it will still be available tomorrow.

## General Idea

The fundamental problem: if no peer is online and no server holds the data, it is gone. Every persistence strategy makes a tradeoff between decentralization and durability.

Common options, each trading off cross-device sync, server dependency, and complexity differently:

- **Browser-local storage** (IndexedDB): no server needed, but data is per-device with no cross-device sync.
- **IPFS pinning**: content-addressed and decentralized, but requires a pinning service for reliable availability.
- **User-owned cloud storage** (Google Drive, S3): familiar, cross-device, but adds a server dependency the user controls.
- **Opt-in encrypted server backup**: convenience of a server with E2EE so the server cannot read the data.

## References

- [MDN: IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
- [IPFS Docs: Persistence and Pinning](https://docs.ipfs.tech/concepts/persistence/)
- [Pinata (IPFS pinning service)](https://www.pinata.cloud/)
