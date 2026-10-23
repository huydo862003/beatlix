---
_label: "Media Routing"
_icon: icon.folder
---

[[directory-index]]

Media routing is the question of how audio and video streams are arranged and forwarded in a multi-party session. With two participants, a direct peer-to-peer connection is trivial. With more, the topology of who connects to whom and how streams are forwarded becomes a core architectural decision.

## The Problem

In a group call with n participants, each person needs to receive streams from every other participant. The naive approach is a full mesh: every peer connects directly to every other peer. This works for small groups but breaks down quickly:

- A participant with 1 Mbps upload in a 6-person room must send 5 simultaneous streams, consuming 5 Mbps of upload bandwidth.
- Most consumer connections cannot sustain this.
- Each new participant multiplies the upload burden on every existing participant.

The problem is not just bandwidth: each WebRTC peer connection has its own ICE negotiation, DTLS handshake, and SRTP session. Maintaining O(n²) connections is expensive on every participant's device.

A media routing layer solves this by introducing a server or a smarter topology that reduces what each participant must upload and manage.

> See [WebRTC](../01-realtime-streaming-protocol-and-api/02-webrtc/index) for the underlying peer connection model this builds on.
