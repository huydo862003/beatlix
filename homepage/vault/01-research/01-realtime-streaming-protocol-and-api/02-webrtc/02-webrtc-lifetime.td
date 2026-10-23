
This section discovers more on the lifetime of a WebRTC session from its establishment to closure.

## Establishing the Connection

Related ${fref("./01-webrtc-connectivity.td")}

::: note
- Signaling is the process of 2 peers contacting a central known point to establish a means of contacting each other directly.
- Once signaling, ICE, and DTLS complete, the session is active and media/data begins to flow.
- ICE continues running in the background for keepalives and consent checks.
:::

During the signaling process:

- **Information exchanged during signaling**:
  - Control messages: These are used to set up, open, close the channel, and handle errors.
  - IP/port information: These are needed so peers can reach each other after the signaling.
  - Media capability negotiation: what codecs and formats each peer supports.
- **Practical setup steps** (manual):
  1. Each peer creates an `RTCPeerConnection` object.
  2. Each peer sets up an `icecandidate` handler to forward candidates to the other peer via the signal server.
    The sender forwards each candidate as it is discovered (trickle ICE) through the same signal server channel used for the offer/answer:
    ```js
    // Peer A: forward candidates to peer B via the signal server
    rtcConnection.addEventListener("icecandidate", (event) => {
    if (event.candidate) {
    signalingServer.send(JSON.stringify({
    to: "peer-b-id",
    type: "ice-candidate",
    candidate: event.candidate,
    }));
    }
    // event.candidate === null means gathering is complete
    });
    ```
    The receiver registers each incoming candidate using `addIceCandidate()`:
    ```js
    // Peer B: register candidates received from peer A
    signalingServer.addEventListener("message", async (event) => {
    const msg = JSON.parse(event.data);
    if (msg.type === "ice-candidate") {
      await rtcConnection.addIceCandidate(msg.candidate);
    }
    });
    ```
    ::: warning
    `addIceCandidate()` must be called **after** `setRemoteDescription()`. If candidates arrive before that (which can happen with trickle ICE), queue them and flush once the remote description is set.
    :::
  3. Each peer sets up a `track` handler to receive media tracks from the remote peer and connect them to a consumer (e.g., a `<video>` element).
     The `track` event fires on `RTCPeerConnection` each time a remote track arrives. The event carries the track and its associated `MediaStream`. You attach the stream to a media element to render it:
    ```js
    const remoteVideo = document.querySelector("#remote-video");
    const remoteStream = new MediaStream();
    remoteVideo.srcObject = remoteStream;

    rtcConnection.addEventListener("track", (event) => {
      remoteStream.addTrack(event.track);
    });
    ```
    ::: note
    Set up this handler **before** the offer/answer exchange. Tracks can arrive as soon as the connection is established, and missing the event means the remote media never renders.
    :::
  4. A unique session token is created and shared so the signal server knows which peers belong to the same session.
  5. Each peer connects to the signal server and joins the session identified by the token.
  6. Offer/answer and ICE candidate exchange begins (see Signaling section).

## ICE Restart

When network conditions change (e.g., switching from cellular to Wi-Fi, or network congestion), the ICE agent can perform an **ICE restart**: it re-gathers candidates and re-runs connectivity checks without tearing down the connection. Media continues flowing on the old candidate pair until the new one is ready, then switches over.

An ICE restart is **not transparent**. It requires a full offer/answer cycle, same as renegotiation. Each side has a distinct role:

**Initiator side**: calls `restartIce()`, which schedules new ICE credentials for the next `createOffer()` call and fires `negotiationneeded`. The `negotiationneeded` handler then creates and sends a new offer as usual:

```js
// detect failure and trigger the restart
rtcConnection.addEventListener("iceconnectionstatechange", () => {
  if (rtcConnection.iceConnectionState === "failed") {
    rtcConnection.restartIce();
  }
});

// negotiationneeded fires after restartIce(), handle it like any renegotiation
rtcConnection.addEventListener("negotiationneeded", async () => {
  const offer = await rtcConnection.createOffer();
  await rtcConnection.setLocalDescription(offer);
  // send offer to the other peer via signal server
});
```

**Recipient side**: receives the new offer via the signal server and processes it like any normal offer (`setRemoteDescription` + `createAnswer` + `setLocalDescription`). No special handling is needed. The browser detects the new ICE credentials in the offer and automatically restarts ICE at the protocol level.
