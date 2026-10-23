---
_label: "History & Sync"
_icon: icon.folder
---

[[directory-index]]

History and sync is the question of how message history is preserved across sessions and kept consistent across a user's devices. Delivery gets the message to the recipient once. History ensures it is still there the next day, on every device, in the right order, and readable only by the intended parties.

## General Idea

The problem has three parts:
- **Where is the log stored?** It may be on a homeserver, distributed across peers, or in user-owned storage. Each choice trades off availability, privacy, and server dependency.
- **How does a second device catch up?** A naive full re-fetch is wasteful. The client needs to know its last-seen position and fetch only what it missed.
- **Who can read it?** History must be encrypted such that only the conversation participants can decrypt it, regardless of where the ciphertext is stored.

See [Decentralized Storage: Persistence](../../04-decentralized-storage/03-persistence/index) for the general persistence tradeoffs these build on.

## References

- [Matrix Specification: Syncing](https://spec.matrix.org/latest/client-server-api/#syncing)
- [Introducing P2P Matrix](https://matrix.org/blog/2020/06/02/introducing-p2p-matrix/)
- [Gun.js Documentation](https://gun.eco/docs/Awesome-GUN)
- [MDN: IndexedDB](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)
