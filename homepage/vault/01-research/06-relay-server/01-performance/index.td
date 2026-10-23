---
_label: "Performance"
_icon: icon.folder
---

[[directory-index]]

Performance of a relay server comes down to two metrics: how many concurrent connections it can hold, and how fast it can route messages between them.

## General Idea

A relay is a message router. Every connected client holds an open WebSocket, and when a message arrives the relay looks up the target room or peer and forwards it.

The bottleneck is usually not CPU but memory (socket buffers) and I/O (writing to many sockets simultaneously). The key concerns are:

- **Connection throughput**: how many concurrent WebSocket connections the server can hold before memory or I/O becomes the bottleneck.
- **Horizontal scaling**: a single process cannot hold all connections indefinitely; pub/sub backends (Redis, NATS) let multiple relay instances share message routing.
- **Write batching**: per-message DB writes do not scale; in-memory buffering and batch flushes reduce I/O pressure.

## References

- [uWebSockets.js](https://github.com/uNetworking/uWebSockets.js) - fastest WebSocket library for Node.js
- [WebSocket servers in JS: Node.js, Bun and Deno in 2026](https://lemire.me/blog/2026/10/10/websocket-servers-in-javascript-node-js-bun-and-deno-in-2026/)
- [Redis Pub/Sub](https://redis.io/docs/manual/pubsub/)
- [NATS Documentation](https://docs.nats.io/)
