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
  ShadowCasterConfig,
} from './provide-renderer';
import {
  CONTAINER_KEY, RENDERER_KEY,
} from './provide-renderer';

/** Register a shadow caster that tracks its DOM element's position */
export function useShadowCaster (
  id: string,
  elementRef: Ref<HTMLElement | undefined>,
  config: ShadowCasterConfig,
) {
  const renderer = inject(RENDERER_KEY, (): never => {
    throw new Error('useShadowCaster called without a provideRenderer ancestor');
  }, true);

  onMounted(() => renderer.registerShadowCaster(id, config));
  onUnmounted(() => renderer.unregisterShadowCaster(id));

  // Track normalized bounds relative to the renderer container
  const containerRef = inject(CONTAINER_KEY, (): never => {
    throw new Error('useShadowCaster called without a provideRenderer ancestor');
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
