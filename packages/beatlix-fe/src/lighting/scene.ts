/**
 * Sprites register emitters/blockers on mount and unregister on unmount
 * Position tracking syncs normalized DOM bounds into the scene
 */

import type {
  InjectionKey, Ref,
} from 'vue';
import {
  computed, inject, onMounted, onUnmounted, provide, reactive, watch,
} from 'vue';
import {
  useElementBounding,
} from '@vueuse/core';
import type {
  SceneInput, ScreenBlocker, ScreenBounds, ScreenEmitter,
} from '@beatlix/lighting';

export interface BlockerConfig {
  /** Z depth (height above floor for shadow extrusion) */
  depth: number;
}

export interface EmitterConfig {
  color: [number, number, number, number];
  intensity: number;
  radius: number;
  coneAngle: number;
  direction: [number, number, number];
  /** Z depth (0 = at window, positive = into room) */
  depth: number;
}

interface SceneContext {
  registerEmitter: (id: string, config: EmitterConfig) => void;
  unregisterEmitter: (id: string) => void;
  registerBlocker: (id: string, config: BlockerConfig) => void;
  unregisterBlocker: (id: string) => void;
  updateBounds: (id: string, bounds: ScreenBounds | undefined) => void;
}

const SCENE_KEY: InjectionKey<SceneContext> = Symbol('room-scene');
const CONTAINER_KEY: InjectionKey<Ref<HTMLElement | undefined>> = Symbol('room-container');

export function provideScene (containerRef: Ref<HTMLElement | undefined>): Ref<SceneInput> {
  /* Separate maps avoid conditional lookups in updateBounds */
  const emitterConfigs = reactive(new Map<string, EmitterConfig>());
  const blockerConfigs = reactive(new Map<string, BlockerConfig>());
  const entityBounds = reactive(new Map<string, ScreenBounds | undefined>());

  /* Helpers close over the reactive maps above */
  function registerEmitter (id: string, config: EmitterConfig) {
    emitterConfigs.set(id, config);
  }

  function unregisterEmitter (id: string) {
    emitterConfigs.delete(id);
    entityBounds.delete(id);
  }

  function registerBlocker (id: string, config: BlockerConfig) {
    blockerConfigs.set(id, config);
  }

  function unregisterBlocker (id: string) {
    blockerConfigs.delete(id);
    entityBounds.delete(id);
  }

  function updateBounds (id: string, bounds: ScreenBounds | undefined) {
    entityBounds.set(id, bounds);
  }

  /* Expose mutation functions to descendants */
  provide(SCENE_KEY, {
    registerEmitter,
    unregisterEmitter,
    registerBlocker,
    unregisterBlocker,
    updateBounds,
  });

  provide(CONTAINER_KEY, containerRef);

  /* Collect registered entities into the WASM input format */
  return computed<SceneInput>(() => {
    const screenEmitters: ScreenEmitter[] = [...emitterConfigs.entries()].map(
      ([
        id,
        config,
      ]) => ({
        bounds: entityBounds.get(id),
        color: config.color,
        intensity: config.intensity,
        radius: config.radius,
        coneAngle: config.coneAngle,
        direction: config.direction,
        depth: config.depth,
      }),
    );

    // Only include blockers with known bounds
    const screenBlockers: ScreenBlocker[] = [...blockerConfigs.entries()]
      .flatMap(([
        id,
        config,
      ]) => {
        const bounds = entityBounds.get(id);

        return bounds === undefined
          ? []
          : [
            {
              bounds,
              depth: config.depth,
            },
          ];
      });

    // Viewport 1x1 matches normalized screen coordinates
    return {
      emitters: screenEmitters,
      blockers: screenBlockers,
      viewport: {
        width: 1,
        height: 1,
      },
    };
  });
}

export function useFixedSceneEmitter (
  id: string,
  config: EmitterConfig,
) {
  const scene = injectScene();

  onMounted(() => scene.registerEmitter(id, config));
  onUnmounted(() => scene.unregisterEmitter(id));
}

export function useSceneBlocker (
  id: string,
  elementRef: Ref<HTMLElement | undefined>,
  config: BlockerConfig,
) {
  const scene = injectScene();

  onMounted(() => scene.registerBlocker(id, config));
  onUnmounted(() => scene.unregisterBlocker(id));

  const bounds = useNormalizedBounds(elementRef);

  watch(bounds, (value) => {
    scene.updateBounds(id, value);
  }, {
    immediate: true,
  });
}

export function useSceneEmitter (
  id: string,
  config: EmitterConfig,
  elementRef: Ref<HTMLElement | undefined>,
) {
  const scene = injectScene();

  onMounted(() => scene.registerEmitter(id, config));
  onUnmounted(() => scene.unregisterEmitter(id));

  const bounds = useNormalizedBounds(elementRef);

  watch(bounds, (value) => {
    scene.updateBounds(id, value);
  }, {
    immediate: true,
  });
}

function injectScene (): SceneContext {
  return inject(SCENE_KEY, (): never => {
    throw new Error('injectScene called without a provideScene ancestor');
  }, true);
}

function useNormalizedBounds (elementRef: Ref<HTMLElement | undefined>) {
  const containerRef = inject(CONTAINER_KEY, (): never => {
    throw new Error('useNormalizedBounds called without a provideScene ancestor');
  }, true);
  const elementBounds = useElementBounding(elementRef);
  const containerBounds = useElementBounding(containerRef);

  return computed(() => {
    if (containerBounds.width.value === 0 || containerBounds.height.value === 0) {
      return undefined;
    }

    return {
      left: (elementBounds.x.value - containerBounds.x.value) / containerBounds.width.value,
      top: (elementBounds.y.value - containerBounds.y.value) / containerBounds.height.value,
      width: elementBounds.width.value / containerBounds.width.value,
      height: elementBounds.height.value / containerBounds.height.value,
    };
  });
}
