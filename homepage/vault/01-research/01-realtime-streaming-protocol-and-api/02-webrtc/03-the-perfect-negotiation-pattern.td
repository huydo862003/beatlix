
> Source: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation

**Perfect negotiation** is the recommended pattern for handling **WebRTC signaling**: both the initial connection and all subsequent renegotiation, using the same code on both peers.

Problems it addresses:

- **Glare (offer collision)**: both peers try to renegotiate at the same time, each sending an offer before receiving the other's. Without a resolution rule, both sides stall.
- **Caller/callee asymmetry**: naive code branches on "am I the initiator?", leading to duplicated signaling logic spread across the app.
- **Async signaling state race**: `signalingState` only updates once `setRemoteDescription(answer)` resolves. An offer arriving in that gap is incorrectly treated as a collision.

## Concepts

### Polite and Impolite Peers

> Resolves glare and caller/callee asymmetry.

Each peer has one fixed role:

- **Polite**: yields on collision. Rolls back its own pending offer and accepts the incoming one.
- **Impolite**: never yields. Drops the incoming offer and keeps its own.

Roles are independent of who initiated the call, so the same code runs on both peers.

### Role Switching

> A consequence of polite/impolite being separate from caller/callee.

Caller/callee can switch mid-session. If the polite peer sent the initial offer but yields during a collision, it becomes the callee for that round. The pattern handles this transparently.

### Guard Flags

> Resolves the async signaling state race.

Two booleans that track what is actually in flight, instead of reading `signalingState` directly:

- **`makingOffer`**: `true` while the local offer is being created and sent.
- **`isSettingRemoteAnswerPending`**: `true` while `setRemoteDescription(answer)` is in flight.

## How It Solves Each Problem

### Glare

Without a rule, both peers stall:

```
Peer A  ---offer--->  Peer B    (B is already in "have-local-offer", not "stable")
Peer B  ---offer--->  Peer A    (A is already in "have-local-offer", not "stable")

Both sides: "I have a pending offer. This incoming offer is invalid. Now what?"
-> no one answers, both sides stall indefinitely
```

With polite/impolite, each side has a predetermined response:

- **Impolite**: drop the incoming offer, keep waiting for an answer to its own.
- **Polite**: roll back its own pending offer, then answer the incoming one.

### Caller/Callee Asymmetry

Without the pattern:

```js
if (isInitiator) {
  // create offer, send it, wait for answer ...
} else {
  // wait for offer, create answer, send it ...
}
```

Both branches grow separately as renegotiation, error handling, and ICE restarts are added. The pattern collapses this because both peers react to the same events:

- **Sending offers**: the caller sends the first offer. After that, `negotiationneeded` fires on whoever's config changes first, either peer can renegotiate.
- **Sending answers**: after `setRemoteDescription(offer)`, both call `setLocalDescription()` to auto-generate and send an answer. The browser decides offer vs answer based on current state.
- **Receiving descriptions**: if it is an offer, answer it. If it is an answer, apply it.

The `polite` flag only comes into play on collision. Everything else is identical:

```js
const polite = /* the only difference between the two peers */;

pc.onnegotiationneeded = async () => { /* same on both peers */ };

signaler.onmessage = async ({ data: { description, candidate } }) => {
  // collision check uses `polite` - everything else is identical
};
```

### Async State Race

Without guard flags:

```js
// BROKEN: signalingState may not have updated yet
if (description.type === "offer" && pc.signalingState !== "stable") {
  // incorrectly treated as collision
}
```

With guard flags:

```js
const readyForOffer =
  !makingOffer &&
  (pc.signalingState === "stable" || isSettingRemoteAnswerPending);
```

Each flag covers one async gap:

**`makingOffer`**

```mermaid
stateDiagram-v2
    [*] --> stable
    stable --> stable : negotiationneeded\nmakingOffer = true
    stable --> have_local_offer : await setLocalDescription()
    have_local_offer --> have_local_offer : signaler.send(offer)\nmakingOffer = false
```

| makingOffer | signalingState | incoming offer treated as |
|---|---|---|
| `true` | `have-local-offer` | collision (real) |
| `false` | `have-local-offer` | not a collision (sending is done) |

**`isSettingRemoteAnswerPending`**

```mermaid
stateDiagram-v2
    [*] --> have_local_offer
    have_local_offer --> have_local_offer : answer arrives\nisSettingRemoteAnswerPending = true
    have_local_offer --> stable : await setRemoteDescription(answer)
    stable --> stable : isSettingRemoteAnswerPending = false
```

| isSettingRemoteAnswerPending | signalingState | incoming offer treated as |
|---|---|---|
| `true` | `have-local-offer` | not a collision (applying answer, almost stable) |
| `false` | `have-local-offer` | collision (real) |

## Implementation

> Full runnable example: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Perfect_negotiation

The same code runs on both peers. The only difference is the value of `polite`.

```js
const pc = new RTCPeerConnection(config);
const polite = /* true or false, determined externally */;
```

### Outgoing: `negotiationneeded` and ICE candidates

- `negotiationneeded` fires when local config changes (track added, codec change, ICE restart, etc.)
- It only fires in `stable` state, so `setLocalDescription()` here always produces an offer.
- `makingOffer` guards against the async lag of `signalingState`.

```js
let makingOffer = false;

pc.onnegotiationneeded = async () => {
  try {
    makingOffer = true;
    await pc.setLocalDescription();
    signaler.send({ description: pc.localDescription });
  } catch (err) {
    console.error(err);
  } finally {
    makingOffer = false;
  }
};

pc.onicecandidate = ({ candidate }) => signaler.send({ candidate });
```

### Incoming: signaling messages

Handles glare resolution, offer/answer processing, and ICE candidate registration.

On a collision:

- **Impolite peer**:
  - Sets `ignoreOffer = true` and returns early.
  -> Dropping the offer and all its subsequent ICE candidates.
- **Polite peer**:
  - Calls `setRemoteDescription()`.
  -> Implicitly rolls back its pending local offer, then answers.

::: note
`signalingState` returning to `stable` only means the offer/answer exchange is done. ICE connectivity checks and candidate gathering continue independently, tracked by `iceConnectionState` and `iceGatheringState`.
:::

```js
let ignoreOffer = false;
let isSettingRemoteAnswerPending = false;

signaler.onmessage = async ({ data: { description, candidate } }) => {
  try {
    if (description) {
      const readyForOffer =
        !makingOffer &&
        (pc.signalingState === "stable" || isSettingRemoteAnswerPending);
      const offerCollision = description.type === "offer" && !readyForOffer;

      ignoreOffer = !polite && offerCollision;
      if (ignoreOffer) return;

      isSettingRemoteAnswerPending = description.type === "answer";
      await pc.setRemoteDescription(description);
      isSettingRemoteAnswerPending = false;

      if (description.type === "offer") {
        await pc.setLocalDescription(); // auto-creates answer
        signaler.send({ description: pc.localDescription });
      }
    } else if (candidate) {
      try {
        await pc.addIceCandidate(candidate);
      } catch (err) {
        if (!ignoreOffer) throw err; // suppress errors from ignored offers
      }
    }
  } catch (err) {
    console.error(err);
  }
};
```
