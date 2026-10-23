---
_label: "Protocol"
_icon: icon.folder
---

[[directory-index]]

The relay protocol defines how clients and the relay communicate: how messages are framed, how rooms are joined, and how signaling is exchanged.

## General Idea

The relay needs to handle room messages: sync commands, chat, and presence. The key concerns are:

- **Message framing**: JSON is easy to debug but verbose; binary formats (MessagePack) reduce payload size.
- **Room membership**: the relay must track which clients are in which room to route messages correctly.
- **Routing rules**: some messages go to one peer (unicast), others to all peers in a room (broadcast).

## References

- [MessagePack](https://msgpack.org/) - binary serialization, drop-in JSON alternative
- [Nostr NIP-01: relay message protocol](https://github.com/nostr-protocol/nostr/blob/master/nips/01.md) - good reference for a minimal relay protocol design
