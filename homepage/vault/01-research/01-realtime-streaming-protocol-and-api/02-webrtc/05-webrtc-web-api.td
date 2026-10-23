
### Web API

The browser runtime exposes various APIs for WebRTC supporting various use cases as detailed in the introduction.

- [`window.RTCPeerConnection`](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection): A class representing a WebRTC connection between the local computer and a remote peer, allowing connection establishment, maintenance and monitoring.
  - `new RTCPeerConnection()`: Establish a connection and returns the connection object.
  - State:
    - `connectionState` instance property: The current state of the connection.
      - `new`
      - `connecting`
      - `connected`
      - `disconnected`
      - `failed`
      - `closed`
    - `iceConnectionState` instance property: Tracks the ICE layer specifically. It is more granular than `connectionState`, useful for reacting to ICE-specific changes (e.g., `disconnected` may recover, `failed` is terminal).
      - `new`
      - `checking`
      - `connected`
      - `completed`
      - `failed`
      - `disconnected`
      - `closed`
    - `iceGatheringState` instance property: Tracks ICE candidate gathering.
      - `new`
      - `gathering`
      - `complete`
    - `signalingState` instance property: Tracks where the connection is in the offer/answer negotiation process.
      - `stable`: no negotiation in progress. Initial state and state after successful negotiation.
      - `have-local-offer`: local peer has set a local offer, waiting for the remote answer.
      - `have-remote-offer`: remote offer received and set, local peer has not answered yet.
      - `have-local-pranswer`: a provisional answer to a remote offer has been set locally.
      - `have-remote-pranswer`: a provisional answer from the remote peer has been received.
      - `closed`: connection is closed.
  - Current (last successfully negotiated) descriptions:
    - `currentLocalDescription` instance property: An [`RTCSessionDescription`](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription) describing _the local end_ as it was _most recently successfully negotiated_, including _generated ICE candidates_ _since that description was instantiated_.
    - `currentRemoteDescription` instance property: An [`RTCSessionDescription`](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription) describing _the remote end_ as it was _most recently successfully negotiated_, including _generated ICE candidates_ _since that description was instantiated_.
  - Pending (under negotiation) descriptions:
    - `pendingLocalDescription` instance property: The local description currently being negotiated. `null` if no negotiation is in progress.
    - `pendingRemoteDescription` instance property: The remote description currently being negotiated. `null` if no negotiation is in progress.
  - Methods during **negotiation**:
    - `setLocalDescription(description?)`: Sets the local description (offer or answer) and triggers ICE candidate gathering. When called with no arguments, the browser auto-generates the appropriate type based on current state. Returns a `Promise<undefined>`.
    - `setRemoteDescription(description)`: Sets the remote peer's offer or answer as the remote description. Returns a `Promise<undefined>`.
    - `createOffer(options?)`: Explicitly creates an SDP offer. Older API, prefer calling `setLocalDescription()` with no args which handles this implicitly.
    - `createAnswer(options?)`: Explicitly creates an SDP answer. Same note as above.
    - `addIceCandidate(candidate)`: Applies a remote ICE candidate received via the signaling channel. Returns a `Promise<undefined>`.
  - Methods for **media**:
    - `addTrack(track, ...streams)`: Adds a `MediaStreamTrack` to the connection. Triggers `negotiationneeded`.
    - `removeTrack(sender)`: Removes a track added via `addTrack()`. Triggers `negotiationneeded`.
    - `getSenders()`: Returns all `RTCRtpSender` objects (outgoing tracks).
    - `getReceivers()`: Returns all `RTCRtpReceiver` objects (incoming tracks).
  - Methods for **data channels**:
    - `createDataChannel(label, options?)`: Creates an `RTCDataChannel` for sending arbitrary data. Must be called before the offer is created so the data channel is included in negotiation.
  - Methods for **stats and teardown**:
    - `getStats(selector?)`: Returns a `Promise<RTCStatsReport>` with connection statistics (bandwidth, packet loss, jitter, etc.).
    - `close()`: Closes the connection and all associated streams. Irreversible.
  - Some events:
    - `connectionstatechange`: Fired when `connectionState` changes (e.g., peer connects, disconnects, or the connection fails).
    - `datachannel`: Fired when the remote peer adds an `RTCDataChannel` to the connection.
    - `icecandidate`: Fired each time a new local ICE candidate is discovered during gathering. You must manually forward it to the remote peer via the signal server:
      ```js
      rtcConnection.addEventListener("icecandidate", (event) => {
      if (event.candidate) {
      // send event.candidate to the other peer via your signal server
      }
      });
      ```
    - `icecandidateerror`: Fired when an error occurs during ICE candidate gathering.
    - `iceconnectionstatechange`: Fired when `iceConnectionState` changes (e.g., ICE starts checking candidates, succeeds, disconnects, or fails).
    - `icegatheringstatechange`: Fired when `iceGatheringState` changes (e.g., gathering starts after `setLocalDescription()`, or completes when all candidates are found).
    - `negotiationneeded`: Fired when the browser detects that negotiation or renegotiation is needed (e.g., after `addTrack()`, `removeTrack()`, or a codec change). The receiver should create an offer and send it to the other peer.
    - `signalingstatechange`: Fired when `signalingState` changes (e.g., moves from `stable` to `have-local-offer` after `setLocalDescription()`, or back to `stable` after a successful negotiation).
- [`window.RTCDataChannel`](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel): Represents a bidirectional peer-to-peer channel for arbitrary data. Obtained via `createDataChannel()` (local) or the `datachannel` event (remote).
  - `send(data)`: Sends a string, `ArrayBuffer`, `Blob`, or `ArrayBufferView`.
  - `close()`: Closes the channel.
  - `readyState`: `connecting`, `open`, `closing`, `closed`.
  - Events: `open`, `close`, `message`, `error`.
- [`window.RTCIceCandidate`](https://developer.mozilla.org/en-US/docs/Web/API/RTCIceCandidate): Represents a single ICE candidate. Passed to `addIceCandidate()` after being received from the remote peer via the signaling channel.
- [`window.RTCSessionDescription`](https://developer.mozilla.org/en-US/docs/Web/API/RTCSessionDescription): Wraps an SDP string with a `type` (`offer`, `answer`, `pranswer`, `rollback`). Used with `setLocalDescription()` and `setRemoteDescription()`.
- [`window.RTCStatsReport`](https://developer.mozilla.org/en-US/docs/Web/API/RTCStatsReport): A map of stats objects returned by `getStats()`. Each entry covers a different aspect of the connection (codec, transport, inbound/outbound RTP, candidate pair, etc.).
