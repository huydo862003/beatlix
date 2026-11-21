import type {
  InjectionKey, Ref,
} from 'vue';
import {
  computed, provide, reactive, ref, watch,
} from 'vue';
import type {
  LightBlocker, LightEmitter, LightingResult, NormalizedRect, SceneInput,
} from '@beatlix/lighting';
import {
  computeLighting,
} from '@beatlix/lighting';

/** Config for a light source, same as LightEmitter minus bounds (tracked automatically) */
export type LightSourceConfig = Omit<LightEmitter, 'bounds'>;

export interface RendererContext {
  registerLightSource: (id: string, config: LightSourceConfig) => void;
  unregisterLightSource: (id: string) => void;
  registerShadowCaster: (id: string, config: ShadowCasterConfig) => void;
  unregisterShadowCaster: (id: string) => void;
  updateBounds: (id: string, bounds: NormalizedRect | undefined) => void;
}

/** Config for a shadow caster, same as LightBlocker minus bounds (tracked automatically) */
export type ShadowCasterConfig = Omit<LightBlocker, 'bounds'>;

export const RENDERER_KEY: InjectionKey<RendererContext> = Symbol('renderer');
export const CONTAINER_KEY: InjectionKey<Ref<HTMLElement | null>> = Symbol('renderer-container');
export const LIGHTING_KEY: InjectionKey<Ref<LightingResult>> = Symbol('renderer-lighting');

/**
 * Set up the renderer for a room container
 * Call once in the layout component
 */
export function provideRenderer (containerRef: Ref<HTMLElement | null>): void {
  // Entity registries for light sources and shadow casters
  const lightSources = reactive(new Map<string, LightSourceConfig>());
  const shadowCasters = reactive(new Map<string, ShadowCasterConfig>());
  const entityBounds = reactive(new Map<string, NormalizedRect | undefined>());

  // Expose registration context to descendant sprites
  provide(RENDERER_KEY, {
    registerLightSource (id: string, config: LightSourceConfig) {
      lightSources.set(id, config);
    },
    unregisterLightSource (id: string) {
      lightSources.delete(id);
      entityBounds.delete(id);
    },
    registerShadowCaster (id: string, config: ShadowCasterConfig) {
      shadowCasters.set(id, config);
    },
    unregisterShadowCaster (id: string) {
      shadowCasters.delete(id);
      entityBounds.delete(id);
    },
    updateBounds (id: string, bounds: NormalizedRect | undefined) {
      entityBounds.set(id, bounds);
    },
  });

  // Container ref for normalized bounds calculation
  provide(CONTAINER_KEY, containerRef);

  // Collect registered entities into the WASM input format
  const sceneInput = computed<SceneInput>(() => {
    const emitters: LightEmitter[] = [...lightSources.entries()].map(
      ([
        id,
        config,
      ]) => ({
        ...config,
        bounds: entityBounds.get(id),
      }),
    );

    // Only include blockers with known bounds
    const blockers: LightBlocker[] = [...shadowCasters.entries()]
      .flatMap(([
        id,
        config,
      ]) => {
        const bounds = entityBounds.get(id);

        return bounds === undefined
          ? []
          : [
            {
              ...config,
              bounds,
            },
          ];
      });

    return {
      emitters,
      blockers,
      viewport: {
        width: 1,
        height: 1,
      },
    };
  });

  // Recompute lighting whenever the scene changes
  const lighting = ref<LightingResult>({
    shadows: [],
  });

  watch(sceneInput, (scene) => {
    lighting.value = computeLighting(scene);
  }, {
    immediate: true,
  });

  provide(LIGHTING_KEY, lighting as Ref<LightingResult>);
}
