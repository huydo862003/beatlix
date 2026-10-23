
**Connectivity** refers to how **two peers find each other and establish a direct connection across the internet**, dealing with various obstacles.

::: details What are the common **connectivity obstacles**?
- **NAT (Network Address Translation)**: most devices are behind a router and don't have a public IP. The peer needs to figure out its public-facing address.
- **Firewalls**: may block incoming connections.
- **Different network topologies**: peers may be on the same LAN, behind different NATs, or in restrictive corporate networks.

ICE is the framework that handles this. Its basic idea is to gather a list of "candidates" (possible network paths) and tries them in order until one works.
:::

## Signaling Service

Before the P2P connection, a server in the middle needs to be present to facilitate creating the WebRTC connection.

The server used to establish WebRTC connections is called the **signal channel** or **signaling service**.

> Signaling is the process of sending control information between two devices to determine the communication protocols, channels, media codecs and formats, and method of data transfer, as well as any required routing information.

> Signaling is like meeting up/registering at a known place to obtain each other's address before directly communicating with each other without going to the same place.

Signaling is not defined in the WebRTC spec intentionally: before the connection exists, the two peers have no way to directly contact each other, and the spec cannot predict every use case. It makes more sense to let developers reuse whatever connectivity they already have (e.g., an existing WebSocket connection) rather than mandating a separate signaling protocol.

> So, WebRTC not totally serverless. However, after the p2p connection is established, the signal channel is no longer involved (except that in extreme cases, relay servers may be required).

::: details Some examples of **signal channel**?

It's broader than you think:
- By email.
- By some physical means like postcards, offline conversation...
:::

## Signaling Process: Offer & Answer

The signaling process is essentially the process of offer & answer.

### Agents

In the signaling process, we have 3 **agents**:

- **Peer A** (initiator): creates and sends the offer.
- **Peer B** (recipient): receives the offer, sends back an answer.
- **Signal server**: relays messages between peers before the P2P connection exists.
  - No standard protocol defined. WebSocket is most common, but anything works.
  - Acts as a simple router: each peer gets an ID on connect, and messages are addressed to a target ID (e.g, `{ to: "peer-b-id", offer: ... }`). The server does not need to understand the WebRTC content.

::: note
WebRTC does not define a signaling protocol.
:::

### Offer & Answer High-Level Contents

The **offer** and **answer** are both **session descriptions** formatted in **SDP (Session Description Protocol)**.

A **session description** describes the configuration of one end of the connection:

- What media it wants to send?
- What codecs it supports?
- Its network address.
- etc.

After this process, each peer will keep a **local description** (describing itself) and a **remote description** (describing the other peer).

### The Signaling Flow

${fref("./_assets/webrtc-complete-diagram.png")}

Related: ${fref("./02-webrtc-lifetime.td")}

The signaling flow is as follows:

1. **Initiator (peer A)** creates an **offer** and registers it as the local **description**.
  - `rtcConnection.createOffer()`: returns an `RTCSessionDescription` (`type: "offer"`, `sdp: "..."`)
  - `rtcConnection.setLocalDescription(offer)`: registers the **offer** on the connection
2. Registering the local **description** automatically triggers ICE candidate gathering: the browser contacts STUN servers to discover the **initiator (peer A)**'s public IP/port.
3. **Initiator (peer A)** sends the **offer** and ICE candidates to the signal server, which forwards them to the recipient.
  - Typically serialized as JSON: `{ "type": "offer", "to": "peer-b-id", "sdp": "..." }`
  - This can also contain additional recipient application-defined identifiers for the server.
4. **Recipient (peer B)** registers the **offer** as the remote **description**, then creates and registers an **answer** as its local **description**.
  - `rtcConnection.setRemoteDescription(offer)`
  - `rtcConnection.createAnswer()` then `rtcConnection.setLocalDescription(answer)`
5. Registering the **answer** triggers ICE candidate gathering on the **recipient (peer B)**'s side as well.
6. **Recipient (peer B)** sends the **answer** and ICE candidates to the signal server, which forwards them to the **initiator (peer A)**.
7. **Initiator (peer A)** registers the **answer** as the remote **description**. Both sides now know each other's configuration and ICE candidates, so the P2P connection is established and media begins to flow.
  - `rtcConnection.setRemoteDescription(answer)`

See: [ICE Candidates](#ice-candidates).

::: note
ICE gathering and connectivity checks also continue running in the background after the connection is established, for keepalives, consent freshness checks (RFC 7675), and ICE restarts when the network changes. Related events can still fire during this time:

- `icecandidate`: if new candidates are discovered (e.g., during an ICE restart).
- `iceconnectionstatechange`: if the connection state changes (e.g., drops to `disconnected`, recovers to `connected`).
- `icegatheringstatechange`: if gathering restarts (e.g., during an ICE restart, state goes back to `gathering`).
:::

::: details What are ICE gathering and connectivity checks?
- **ICE candidate gathering**: triggered by the WebRTC engine when a local peer description is registered on the peer connection. Each peer contacts STUN/TURN servers to collect its candidates and forwards them to the other peer via the signal server using trickle ICE, so candidates are exchanged before signaling is even complete.
- **ICE connectivity checks**: as soon as both peers have any of each other's candidates, they start probing candidate pairs via STUN binding requests, concurrently with gathering. The best working pair is selected. `prflx` candidates can be discovered here.
:::

After the WebRTC connection is obtained, both peers use DTLS (Datagram Transport Layer Security) to encrypt the connection.

### Connection Failure

Even after a successful offer/answer exchange, the connection can still fail at the ICE stage if no working candidate pair is found (e.g., both peers behind symmetric NAT with no TURN server). The `iceConnectionState` changes to `"failed"`. You can attempt an **ICE restart** before giving up on the connection entirely.

The offer/answer process happens both when:

- A call is first established.
- The configuration needs to change (renegotiation).

### Data Format

Offer and answer are **session descriptions** formatted in **SDP (Session Description Protocol)** (RFC 8866).

SDP is a plain text format with `key=value` pairs describing the configuration of a media endpoint:

- kind of media
- codec
- transfer protocol
- IP address
- port, etc.

```
v=0
o=alice 2890844526 2890844526 IN IP4 host.example.com
s=-
c=IN IP4 host.example.com
t=0 0
m=audio 49170 RTP/AVP 0
a=rtpmap:0 PCMU/8000
m=video 51372 RTP/AVP 31
a=rtpmap:31 H261/90000
```

Each peer maintains two descriptions:

- **Local description**: describes itself (`localDescription`).
- **Remote description**: describes the other peer (`remoteDescription`).

## Renegotiation

Renegotiation is needed when the connection configuration changes after it is established.

Some examples:

- Adding/removing tracks.
- Changing codecs.
- Switching cameras.

It is not handled automatically: you must manually trigger a new offer/answer cycle, **identical to the initial signaling flow**.

The browser fires a `negotiationneeded` event on the **same peer** that made the change, telling it "your local configuration changed, renegotiate with the other side." The other peer is not involved until it receives the new offer via the signal server.

For example, if peer A calls `addTrack()`, peer A's browser fires `negotiationneeded` on peer A's `RTCPeerConnection`. Peer A then creates a new offer and sends it to peer B. Peer B just responds normally.

You listen for this event and kick off a new offer:

```js
rtcConnection.addEventListener("negotiationneeded", async () => {
  const offer = await rtcConnection.createOffer();
  await rtcConnection.setLocalDescription(offer);
  // send offer to the other peer via signal server
});
```

**Pending and current descriptions**:

During renegotiation, an offer might be rejected (e.g., incompatible format). To handle this without disrupting the active connection, WebRTC tracks two states per description:

- **Current description** (`currentLocalDescription`, `currentRemoteDescription`): the description currently in use, agreed upon by both sides.
- **Pending description** (`pendingLocalDescription`, `pendingRemoteDescription`): a description under consideration after a `setLocalDescription()` or `setRemoteDescription()` call.

Once agreed upon, the pending description becomes the current description and pending is cleared. `localDescription` and `remoteDescription` return the pending description if one exists, otherwise the current.

**ICE rollback**:

When renegotiation fails on an active connection, instead of dropping the call you can rollback to the last stable SDP configuration. Two ways to trigger it:

- **Programmatically**: set a description with `type: "rollback"`.
- **Automatically**: when a peer in `have-local-offer` state receives an offer from the remote peer (a "glare" situation where both sides tried to renegotiate simultaneously), the browser automatically rolls back the local offer so the remote offer can be processed instead.

**ICE restart**:

When the network changes (e.g., switching from Wi-Fi to mobile), the existing ICE candidates may no longer be valid. An ICE restart re-gathers candidates and re-runs connectivity checks without tearing down the connection. See: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Session_lifetime#ice_restart.

## ICE Candidates

An ICE candidate describes **a possible network path** through which a peer can be reached.

ICE has two phases:

1. **Candidate gathering**: each peer contacts STUN/TURN servers to collect its candidates (host, srflx, relay). Candidates are sent to the other peer via the signal server using **trickle ICE**: forwarded as discovered rather than waiting for all of them. The `icecandidate` event fires on `RTCPeerConnection` each time a new candidate is ready.
2. **Connectivity checks**: once both peers have each other's candidates, they probe each candidate pair by sending STUN binding requests. `prflx` candidates can only appear at this stage. The best working pair is selected for the connection.

ICE candidates use **UDP** (preferred, faster, better for media) or **TCP** (fallback when UDP is unavailable or restricted).

Candidate types:

- **Host** (`host`): the device's direct local IP. Works if both peers are on the same network.
- **Peer reflexive** (`prflx`): an IP discovered during ICE connectivity checks, when the other peer observes the source address of an incoming packet.

::: details How does `prflx` work?
Discovered during ICE connectivity checks, not STUN discovery:

1. Peer A sends a STUN connectivity check to peer B through its symmetric NAT.
2. The NAT assigns a public IP:port specifically for this connection to peer B.
3. Peer B sees the source address of the incoming packet and adds it as a `prflx` candidate.
4. Peer B replies to that address. Peer A's NAT lets it through since it matches the outbound mapping.

Peer A's outbound packet punches the hole; peer B aims its reply at that hole.

**Limitation**: only works if one peer is behind symmetric NAT and the other is not. If both are behind symmetric NAT, neither can punch a hole since you need the other's mapping to send, but the mapping only exists after they send. TURN relay is the only solution.
:::

- **Server reflexive** (`srflx`): the public IP/port discovered via STUN. Works for most NAT configurations.

::: details Symmetric vs asymmetric NAT
- **Asymmetric NAT** (full cone / restricted cone): maps an internal IP:port to a fixed public IP:port. STUN discovers this address reliably since the mapping is consistent regardless of destination.
- **Symmetric NAT**: creates a different public IP:port mapping per destination. The address STUN discovers is only valid for the STUN server connection, not for reaching peers. This is why `srflx` candidates fail with symmetric NAT.
:::

- **Relay** (`relay`): the address of a TURN server. Used when direct connection fails.

One peer is designated the **controlling agent** (makes the final decision on which candidate pair to use) and the other is the **controlled agent** (waits to be told which pair to use). In practice this distinction doesn't matter to application code.
