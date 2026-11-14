// Types mirroring the WASM boundary (serde camelCase)

export interface LightingResult {
  shadows: ShadowPolygon[];
}

export interface SceneInput {
  emitters: ScreenEmitter[];
  blockers: ScreenBlocker[];
  viewport: ViewportSize;
}

export interface ScreenBlocker {
  /** Normalized bounds [0,1] relative to room container */
  bounds: ScreenBounds;
  /** Z depth (height above floor for shadow extrusion) */
  depth: number;
}

export interface ScreenBounds {
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface ScreenEmitter {
  /** Normalized bounds [0,1] relative to room container, absent for fixed-position lights */
  bounds?: ScreenBounds;
  color: [number, number, number, number];
  intensity: number;
  radius: number;
  coneAngle: number;
  direction: [number, number, number];
  /** Z depth (0 = at window, positive = into room) */
  depth: number;
}

export interface ShadowPolygon {
  vertices: [number, number][];
  color: [number, number, number, number];
  intensity: number;
}

export interface ViewportSize {
  width: number;
  height: number;
}

// WASM initialization

interface WasmModule {
  compute_lighting: (scene: unknown) => LightingResult;
}

let wasmModule: WasmModule | undefined;
let loadPromise: Promise<void> | undefined;

/**
 * Initialize the WASM lighting engine.
 * Safe to call multiple times, only loads once.
 * Resets on failure so subsequent calls can retry.
 */
export async function loadLighting (): Promise<void> {
  if (wasmModule) return;
  if (loadPromise) return loadPromise;

  loadPromise = (async () => {
    try {
      const wasm = await import('../wasm.js');

      wasmModule = wasm as unknown as WasmModule;
    } catch (error) {
      loadPromise = undefined;
      throw error;
    }
  })();

  return loadPromise;
}

/** Compute shadow polygons from a scene. Returns undefined if the engine is not yet loaded. */
export function computeLighting (scene: SceneInput): LightingResult | undefined {
  if (!wasmModule) return undefined;

  try {
    return wasmModule.compute_lighting(scene);
  } catch {
    return undefined;
  }
}
