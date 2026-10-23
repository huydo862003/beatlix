
The **Web Audio API** is a **browser API** for **processing and synthesizing audio** in web applications. It provides a high-precision, low-latency audio system that goes far beyond what a `<audio>` element can do:
  - A `<audio>` element can play a file.
  - The Web Audio API can play, generate, route, filter, analyze, spatialize, and schedule audio with sample-accurate timing, all in the browser.

It is built around an **audio graph**: nodes connected together where audio flows from sources through effects to a destination (speakers or a `MediaStream`).

```
Source(s) --> Effect(s) --> Destination
```

Combined with the Media Capture and Streams API, it can process live microphone input in real time (e.g. noise filtering, voice effects).

## References

- MDN: https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API
- Spec: https://webaudio.github.io/web-audio-api/

## Concepts

The API is built around the concept of an audio graph: a network of nodes, each performing one operation on the audio signal.

| Term | Web API | Meaning |
|---|---|---|
| Audio context | `AudioContext` | The container for the entire audio graph. All nodes are created from it. |
| Node | `AudioNode` | A single processing unit in the graph (source, effect, or destination). |
| Source node | e.g. `OscillatorNode`, `AudioBufferSourceNode` | Produces audio: a generated tone, a loaded file, a media element, or a `MediaStream`. |
| Effect node | e.g. `GainNode`, `BiquadFilterNode` | Transforms audio passing through it: volume, filtering, reverb, delay, etc. |
| Destination node | `AudioDestinationNode`, `MediaStreamAudioDestinationNode` | Final sink: speakers, or a `MediaStream` to pipe elsewhere (e.g. WebRTC). |
| Audio param | `AudioParam` | A time-varying parameter on a node (e.g. gain value, filter frequency). Can be automated or connected to another node's output. |

### Audio Graph

Nodes are connected via `node.connect(otherNode)`. Audio flows from sources to destinations through any number of effect nodes. The graph can branch and merge.

```js
const ctx = new AudioContext();

const oscillator = ctx.createOscillator();   // source
const gain = ctx.createGain();               // effect

oscillator.connect(gain);
gain.connect(ctx.destination);              // destination = speakers

oscillator.start();
oscillator.stop(ctx.currentTime + 1);
```

### AudioContext

- The root object. All nodes are created through it (`ctx.createGain()`, `ctx.createOscillator()`, etc.).
- Has a `currentTime` clock (in seconds) for sample-accurate scheduling.
- Starts in `suspended` state in some browsers until a user gesture resumes it.

```js
// Must resume after user interaction
document.addEventListener("click", () => ctx.resume());
```

### AudioParam

A parameter on a node that can change over time. Can be set directly or scheduled:

```js
gain.gain.value = 0.5;                          // set immediately
gain.gain.linearRampToValueAtTime(0, ctx.currentTime + 2); // fade out over 2s
```

AudioParams can also receive audio-rate signals from other nodes, enabling modulation (e.g. LFO controlling filter frequency).

## Common Flows

### Play a loaded audio file

```js
const ctx = new AudioContext();
const response = await fetch("sound.mp3");
const buffer = await ctx.decodeAudioData(await response.arrayBuffer());

const source = ctx.createBufferSource();
source.buffer = buffer;
source.connect(ctx.destination);
source.start();
```

### Process microphone input in real time

```js
const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
const ctx = new AudioContext();

const mic = ctx.createMediaStreamSource(stream);
const filter = ctx.createBiquadFilter();
filter.type = "highpass";
filter.frequency.value = 100;

mic.connect(filter);
filter.connect(ctx.destination);
```

### Output to a MediaStream (e.g. for WebRTC)

```js
const dest = ctx.createMediaStreamDestination();
sourceNode.connect(dest);

// dest.stream is a MediaStream, pipe it to RTCPeerConnection
pc.addTrack(dest.stream.getAudioTracks()[0], dest.stream);
```

### Frequency analysis for visualization

```js
const analyser = ctx.createAnalyser();
analyser.fftSize = 2048;
sourceNode.connect(analyser);
analyser.connect(ctx.destination);

const data = new Uint8Array(analyser.frequencyBinCount);
analyser.getByteFrequencyData(data); // call on each animation frame
```

## Pitfalls

- **Autoplay policy**: browsers block audio until a user gesture. Always resume the `AudioContext` inside a user event handler.
- **`ScriptProcessorNode` is deprecated**: use `AudioWorklet` for custom audio processing. It runs off the main thread and avoids glitches.
- **`AudioBufferSourceNode` is one-shot**: it can only be started once. Create a new one each time you want to play the buffer.
- **Disconnect nodes when done**: connected nodes stay alive even if you lose the reference. Call `node.disconnect()` to free resources.
- **Context limit**: browsers limit the number of `AudioContext` instances per page. Reuse one context across the app.

## Web API

- [`window.AudioContext`](https://developer.mozilla.org/en-US/docs/Web/API/AudioContext): Root object. Creates and owns all nodes.
  - `currentTime`: high-precision clock in seconds.
  - `destination`: the default output node (speakers).
  - `state`: `"suspended"`, `"running"`, `"closed"`.
  - `resume()`/`suspend()`/`close()`.
  - `decodeAudioData(arrayBuffer)`: decodes an encoded audio file into an `AudioBuffer`. Returns `Promise<AudioBuffer>`.
  - Factory methods: `createOscillator()`, `createGain()`, `createBiquadFilter()`, `createBufferSource()`, `createMediaStreamSource()`, `createMediaStreamDestination()`, `createAnalyser()`, etc.
- **Source nodes**:
  - [`OscillatorNode`](https://developer.mozilla.org/en-US/docs/Web/API/OscillatorNode): generates a periodic waveform (sine, square, sawtooth, triangle). `frequency`, `type`.
  - [`AudioBufferSourceNode`](https://developer.mozilla.org/en-US/docs/Web/API/AudioBufferSourceNode): plays a pre-decoded `AudioBuffer`. One-shot.
  - [`MediaElementAudioSourceNode`](https://developer.mozilla.org/en-US/docs/Web/API/MediaElementAudioSourceNode): wraps a `<audio>` or `<video>` element as a source.
  - [`MediaStreamAudioSourceNode`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamAudioSourceNode): wraps a `MediaStream` (e.g. microphone) as a source.
- **Effect nodes**:
  - [`GainNode`](https://developer.mozilla.org/en-US/docs/Web/API/GainNode): volume control. `gain` AudioParam.
  - [`BiquadFilterNode`](https://developer.mozilla.org/en-US/docs/Web/API/BiquadFilterNode): lowpass, highpass, bandpass, etc. `frequency`, `Q`, `type`.
  - [`DelayNode`](https://developer.mozilla.org/en-US/docs/Web/API/DelayNode): delays signal by a configurable amount.
  - [`ConvolverNode`](https://developer.mozilla.org/en-US/docs/Web/API/ConvolverNode): convolution reverb using an impulse response buffer.
  - [`DynamicsCompressorNode`](https://developer.mozilla.org/en-US/docs/Web/API/DynamicsCompressorNode): reduces dynamic range (loudness normalization).
  - [`StereoPannerNode`](https://developer.mozilla.org/en-US/docs/Web/API/StereoPannerNode): left/right stereo panning. `pan` AudioParam.
  - [`PannerNode`](https://developer.mozilla.org/en-US/docs/Web/API/PannerNode): 3D spatial audio positioning.
  - [`AnalyserNode`](https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode): does not modify audio. Exposes frequency/waveform data for visualization.
  - [`AudioWorkletNode`](https://developer.mozilla.org/en-US/docs/Web/API/AudioWorkletNode): runs custom DSP code (defined in an `AudioWorkletProcessor`) off the main thread.
- **Destination nodes**:
  - [`AudioDestinationNode`](https://developer.mozilla.org/en-US/docs/Web/API/AudioDestinationNode): `ctx.destination`. Outputs to speakers.
  - [`MediaStreamAudioDestinationNode`](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamAudioDestinationNode): outputs to a `MediaStream`. Use to pipe processed audio into WebRTC or `MediaRecorder`.
