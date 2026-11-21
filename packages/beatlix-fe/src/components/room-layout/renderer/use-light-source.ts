import type {
  Ref,
} from 'vue';
import {
  computed, inject, onMounted, onUnmounted, watch,
} from 'vue';
import {
  useElementBounding,
} from '@vueuse/core';
import type {
  LightSourceConfig,
} from './provide-renderer';
import {
  CONTAINER_KEY, RENDERER_KEY,
} from './provide-renderer';

/** Register a fixed light source (no DOM element, e.g. moonlight) */
export function useFixedLightSource (
  id: string,
  config: LightSourceConfig,
) {
  const renderer = inject(RENDERER_KEY, (): never => {
    throw new Error('useFixedLightSource called without a provideRenderer ancestor');
  }, true);

  onMounted(() => renderer.registerLightSource(id, config));
  onUnmounted(() => renderer.unregisterLightSource(id));
}

/** Register a light source that tracks its DOM element's position */
export function useLightSource (
  id: string,
  config: LightSourceConfig,
  elementRef: Ref<HTMLElement | undefined>,
) {
  const renderer = inject(RENDERER_KEY, (): never => {
    throw new Error('useLightSource called without a provideRenderer ancestor');
  }, true);

  onMounted(() => renderer.registerLightSource(id, config));
  onUnmounted(() => renderer.unregisterLightSource(id));

  // Track normalized bounds relative to the renderer container
  const containerRef = inject(CONTAINER_KEY, (): never => {
    throw new Error('useLightSource called without a provideRenderer ancestor');
  }, true);

  const elementBounds = useElementBounding(elementRef);
  const containerBounds = useElementBounding(containerRef);

  const bounds = computed(() => {
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

  watch(bounds, (value) => {
    renderer.updateBounds(id, value);
  }, {
    immediate: true,
  });
}
