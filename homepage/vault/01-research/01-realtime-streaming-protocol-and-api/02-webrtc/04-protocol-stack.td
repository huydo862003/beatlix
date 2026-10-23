
WebRTC is not a single protocol. It is a stack of layered protocols, each responsible for one concern.

```mermaid
sequenceDiagram
    participant App
    participant Signaling
    participant ICE as ICE (STUN/TURN)
    participant DTLS
    participant Media as SRTP/SRTCP
    participant Data as SCTP

    App->>Signaling: SDP offer/answer exchange
    App->>ICE: gather candidates, run connectivity checks
    ICE->>DTLS: path established, start handshake
    DTLS->>Media: keys ready, media flows
    DTLS->>Data: keys ready, data channels open
```

Protocols are listed below in the order they participate in a WebRTC session.

### 1. NAT (Network Address Translation)

Background context for why traversal is needed at all.

- Routers map private IP:port pairs to a single public IP with unique ports.
- Most devices have no public IP. Peers cannot reach each other directly.
- Different NAT types (full-cone, restricted, symmetric) affect which strategies succeed.

### 2. SDP (Session Description Protocol)

The first thing exchanged. Peers negotiate session parameters before any media or data flows.

- Not a transport protocol. A **text format** describing a multimedia session.
- Negotiated via offer/answer (signaling). Covers: codecs, formats, resolutions, encryption fingerprints, ICE credentials.
- Each line: `<type>=<value>` (e.g., `m=audio`, `a=rtpmap`, `a=ice-ufrag`).
- Spec: RFC 8866.

### 3. ICE (Interactive Connectivity Establishment)

Runs concurrently with SDP exchange. Finds a working network path between peers.

- Gathers **candidates** (possible network paths): host, server-reflexive (via STUN), relayed (via TURN).
- Runs connectivity checks on all candidate pairs and picks the best working one.
- Falls back from direct to relayed automatically.

### 4. STUN (Session Traversal Utilities for NAT)

Used by ICE during candidate gathering.

- Discovers the peer's **public IP and port** as seen from outside its NAT.
- Client sends a binding request to a STUN server; server replies with the client's public address.
- Cheap and stateless. Fails for symmetric NAT (most mobile networks). TURN is the fallback.

### 5. TURN (Traversal Using Relays Around NAT)

Used by ICE as a fallback when direct and STUN-assisted paths fail.

- Peer connects to a TURN server, which **relays all traffic** between peers.
- Higher latency and bandwidth cost. Only used when necessary.

### 6. DTLS (Datagram Transport Layer Security)

Runs after ICE establishes a path. Sets up encryption before any media or data flows.

- TLS adapted for **UDP** (handles packet loss, reordering).
- Both peers perform a DTLS handshake over the ICE-selected candidate pair.
- Derived keys are handed to SRTP for media encryption and used directly for SCTP.

### 7. SRTP and SRTCP (Secure RTP / Secure RTCP)

Active for the duration of the call. Carries encrypted audio and video.

- **SRTP**: carries audio/video packets. Each packet includes payload type, sequence number, timestamp, SSRC (stream identifier).
- **SRTCP**: companion control protocol. Reports packet loss, jitter, round-trip time. Used by the browser to adapt bitrate in real time.
- Both encrypted with keys from the DTLS handshake.

### 8. SCTP (Stream Control Transmission Protocol)

Active for the duration of any open data channels. Carries arbitrary application data.

- Runs over DTLS, inheriting encryption and NAT traversal.
- Supports multiple independent streams per connection.
- Reliability and ordering are configurable per channel: reliable, partial-reliable, or unreliable.
- Exposed via `RTCDataChannel`; the underlying transport is `RTCSctpTransport`.
