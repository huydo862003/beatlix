
WebSocket is a **protocol and browser API** for **client-server communication**. It allows **two-way communication** between the **user's browser** and the **server**.

Unlike WebRTC, WebSocket requires the server to relay all messages. WebRTC enables peer-to-peer communication (browser-to-browser) after an initial signaling phase, so ongoing data does not pass through the server.

## Motivation

In most of web applications, the client and server communicates via the HTTP protocol: The client requests a resource & the server responds.

In some cases, this is not enough:

- In realtime use cases, for example, when the client needs to be notified of an event/change detected by the server, the server may want to be **the one that initiate a message** rather than the client.
- In collaboration use cases, a concurrent user can make some changes, and the other user wants to be notified of those changes.

Although in these cases, with HTTP, one can perform **polling** or **long polling** to partially resolve the posed problems. It may be best in terms of performance and also natural to let the server proactively notifies its clients of events.

Therefore, the browser exposes the WebSocket API, which implements the WebSocket protocol, to support these use cases.

## References & Libraries

- MDN: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API
- Socket.IO: https://socket.io/
- Various tools: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API#tools

## General

This section covers all general ideas of Websocket so one can basically use it and have a high-level understanding of how it works before focusing more into the details.

Websocket is:

- A **protocol and browser API** (`WebSocket` constructor, `onmessage`, `send()`, etc.).
- Allows 2-way communication between the user's browser and the server.
- Requires a persistent server to relay all messages.

### Protocol

This section focuses on the WebSocket protocol itself, it's lifecycle, connection state, message format.

#### Websocket Initiation

The handshake mechanism depends on the HTTP version:

- **HTTP/1.1** (RFC 6455): The standard mechanism. The flow:
  1. Client opens a TCP connection to the server.
  2. Over that TCP connection, client sends an HTTP/1.1 GET request with upgrade headers (`Upgrade: websocket`, `Connection: Upgrade`, etc.).
  3. Server responds with **101 Switching Protocols**.
  4. The same TCP connection is then used for WebSocket frames instead of HTTP.
  For `wss://`, a TLS handshake is inserted between steps 1 and 2, so the HTTP upgrade request is sent over an encrypted channel. This is why WebSocket works on ports 80/443 and passes through most firewalls.
- **HTTP/2** (RFC 8441): The `Upgrade` header does not exist in HTTP/2. Instead, WebSocket is bootstrapped via an extended `CONNECT` method with a `:protocol: websocket` pseudo-header. Browser support exists but is limited; in practice most browsers still negotiate WebSocket over HTTP/1.1 even when HTTP/2 is available.
- **HTTP/3** (RFC 9220): Uses the same extended `CONNECT` approach as HTTP/2 but over QUIC. Support is very limited.

There are other HTTP headers related to Websocket initiation and handshaking: https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API#related_http_headers.

#### URI Schemes

WebSocket uses two URI schemes: `ws://` (unencrypted) and `wss://` (TLS-encrypted). Use `wss://` when the page is served over HTTPS, as browsers block `ws://` connections from HTTPS pages (mixed content rules).

#### Data Formats

WebSocket messages can carry two types of data:

- **Text** - UTF-8 encoded strings.
- **Binary** - `ArrayBuffer` or `Blob` (in JS).

The type of received data is controlled via `WebSocket.binaryType` in the Web API (`"blob"` by default, can be set to `"arraybuffer"`).

#### Subprotocols

WebSocket itself does not define a message format. **Subprotocols** are application-level protocols layered on top of WebSocket that define how messages are structured (e.g., STOMP, MQTT, GraphQL over WebSocket).

A subprotocol is negotiated during the handshake via the `Sec-WebSocket-Protocol` header. The client proposes one or more subprotocols, and the server picks one. The agreed-upon subprotocol is accessible via `WebSocket.protocol`.

The `WebSocket` constructor accepts subprotocols as a second argument:

```js
new WebSocket("wss://example.com", ["stomp", "mqtt"]);
```

### Browser API

The browser runtime exposes these APIs:

- [`window.WebSocket`](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket) class: A class allowing users to create a WebSocket object. The object contains APIs to create, manage a WebSocket connection and also communicate via the connection.
  - `new WebSocket()`: Creates and returns a `WebSocket` object.
  - `WebSocket.readyState` property: The current state of the connection. One of `CONNECTING` (0), `OPEN` (1), `CLOSING` (2), or `CLOSED` (3).
  - `WebSocket.close()` instance method: Close the connection.
  - `WebSocket.send()` instance method: Enqueue data to be transmitted.
  - `WebSocket.addEventListener()` allows registering the following events:
    - `open`: Fired when the connection is open.
    - `message`: Fired when data is received.
    - `error`: Fired when the connection **has been closed because of an error**.
    - `close`: Fired when the connection is closed.

There is a **limitation** with the `WebSocket` API, it's impossible to apply **backpressure**, so there must be an out-of-band mechanism to regulate the connection between the server and the client to avoid filling up the client's memory/overloading its CPU and causing it to become unresponsive. For this problem, there is an unstable experimental API `WebSocketStream`.

## Advanced

This section discusses some infrequents problems when using WebSocket.

### Stale WebSocket Connections

A stale connection is when the TCP connection has silently died (e.g., due to a network interruption, NAT timeout, or the client going offline) but neither side has been notified, so both still think the connection is open.

Neither `close` nor `error` fires in this case:

- `close` only fires when a proper WebSocket closing handshake completes (a close frame is exchanged). A silent disconnect sends no close frame.
- `error` only fires when the WebSocket is aware something went wrong. For a silent disconnect there is nothing to detect, so it does not fire either.

For reference, how each scenario plays out:

| Scenario | `error` | `close` |
| --- | --- | --- |
| Graceful close (`close()` called) | no | yes |
| Detected failure (TLS error, connection refused) | yes | yes (right after) |
| Silent disconnect (network cut, NAT timeout) | no | no (until TCP gives up, which for idle connections can take minutes or never) |

TCP has a built-in keepalive mechanism, but it is slow by default (hours in some OS configurations) and unreliable across proxies and networks. For idle connections with no traffic, TCP never retransmits anything and never detects that the peer is gone.

NAT middleboxes can also silently drop connection state after an idle period without notifying either endpoint.

#### Heartbeats

A common solution to the stale connections is an application-level **heartbeat**: periodically send a ping and expect a pong back. If no pong arrives within a timeout, the connection is treated as dead and closed/reconnected.

Heartbeats also help with **proxy and firewall timeouts** - some proxies close idle long-lived connections, so a heartbeat keeps the connection active.

### WebSocket Reconnection

The browser `WebSocket` API has no auto-reconnect. To reconnect, you create a new `WebSocket` object (there is no reconnect method). A basic implementation:

```js
let ws;

function connect() {
  ws = new WebSocket("wss://example.com");

  ws.addEventListener("open", () => { /* reattach state, resend queued messages */ });
  ws.addEventListener("close", () => setTimeout(connect, 3000)); // reconnect after 3s
  ws.addEventListener("message", (e) => { /* handle message */ });
}

connect();
```

For **exponential backoff**, increase the delay on each retry and reset it on a successful `open`. Libraries like `reconnecting-websocket` or Socket.IO handle this automatically.

#### Delivery Guarantees

WebSocket has no built-in delivery acknowledgment. `send()` is fire-and-forget: it does not return a promise or throw if the message never reaches the server. TCP guarantees delivery while the connection is alive, but if the connection dies mid-transmission you cannot know whether the last message(s) made it. You can check `WebSocket.bufferedAmount` to see how much data is still queued unsent, but that is the extent of visibility the API provides.

If you need delivery guarantees, implement **application-level ACKs**: assign each message an ID, have the server acknowledge receipt, and on reconnect resend anything unacknowledged.

### Message Format

WebSocket has no built-in message envelope. In practice, you define your own format, commonly JSON with a `type` field and a `payload`:

```json
{ "type": "chat_message", "payload": { "text": "hello" } }
```

Or use a subprotocol (e.g., STOMP) that defines this for you.

### Authentication

WebSocket has no built-in auth mechanism. Common approaches:

- **Cookies** - sent automatically with the WebSocket handshake (same as HTTP). The cleanest solution if the frontend and backend share the same domain.
- **First message** - send the auth token as the first message after the connection opens. The server treats the connection as unauthenticated until it receives a valid token, then upgrades it.
- **Query param** - pass the token in the URL (e.g., `wss://example.com?token=...`). Avoid this: URLs are logged in full by servers, proxies, and load balancers, so the token ends up in plain text in log files.

### Distributed WebSocket Servers

WebSocket connections are stateful and persistent: each connection is held in memory on a specific server instance. In a horizontally scaled setup (multiple instances behind a load balancer), this causes a problem: a message or event on server 1 has no way to reach clients connected to server 2.

Common solutions:

- **Sticky sessions** - the load balancer always routes a client to the same server instance. Simple, but does not solve broadcasting across all clients.
- **Pub/sub layer** - server instances share a **message bus**: a shared communication channel that processes can publish to and subscribe from.
  1. A sender publishes a message to a named channel without knowing who receives it.
  2. All subscribers on that channel get the message.
  3. When an event occurs on one instance, it publishes to the bus (e.g, a Redis channel), and all other instances receive it and forward to their locally connected clients.
  Redis pub/sub is the simplest option while Kafka is more robust and also persists messages (useful for replay and delivery guarantees).

### Multi-Client Broadcast

Broadcasting to all connected clients is straightforward on a single server (iterate over connections and send). In a distributed setup, a pub/sub layer is required as described above.

For **targeted broadcast** (e.g, only clients in a specific chat room), you also need shared state tracking which clients belong to which room. Each server instance publishes to a room-specific channel, and all instances forward to their locally connected clients in that room.

Socket.IO's Redis adapter implements this pattern, so calling `io.to("room").emit(...)` works transparently across instances.
