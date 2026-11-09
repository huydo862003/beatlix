import {
  type Ref, computed, inject, onMounted, onUnmounted, provide, watch,
} from 'vue';
import {
  useElementBounding,
} from '@vueuse/core';
import type {
  Position, SurfaceKind,
} from '../components/types';
import {
  SilhouetteShape,
} from '../components/types';
import type {
  EntityDefinition, EntityId,
} from '../entities/types';
import type {
  World,
} from '../world';
import {
  useSvgSilhouette,
} from './useSvgSilhouette';

export const ROOM_WORLD_KEY = Symbol('room-world');
export const ROOM_CONTAINER_KEY = Symbol('room-container');

export function provideRoomContainer (containerRef: Ref<HTMLElement | undefined>) {
  provide(ROOM_CONTAINER_KEY, containerRef);
}

// Read light pools falling on a specific surface
export function useLightPoolsOnSurface (receiverId: EntityId) {
  const world = useWorld();

  return computed(() => {
    if (!world) {
      return [];
    }

    return world.lightPools.value.filter((pool) => pool.receiverId === receiverId);
  });
}

// Normalize element bounds to 0-1 relative to room container
export function useNormalizedBounds (elementRef: Ref<HTMLElement | undefined>) {
  const containerRef = inject<Ref<HTMLElement | undefined>>(ROOM_CONTAINER_KEY);
  const elementBounds = useElementBounding(elementRef);
  const containerBounds = containerRef ? useElementBounding(containerRef) : undefined;

  return computed(() => {
    if (!containerBounds || containerBounds.width.value === 0 || containerBounds.height.value === 0) {
      return undefined;
    }

    return {
      x: (elementBounds.x.value - containerBounds.x.value) / containerBounds.width.value,
      y: (elementBounds.y.value - containerBounds.y.value) / containerBounds.height.value,
      w: elementBounds.width.value / containerBounds.width.value,
      h: elementBounds.height.value / containerBounds.height.value,
    };
  });
}

export function useRoomEntity (definition: EntityDefinition) {
  const world = useWorld();

  if (!world) {
    return;
  }

  onMounted(() => {
    world.spawn(definition);
  });

  onUnmounted(() => {
    world.despawn(definition.id);
  });

  return world;
}

// Read shadows falling on a specific surface
export function useShadowsOnSurface (receiverId: EntityId) {
  const world = useWorld();

  return computed(() => {
    if (!world) {
      return [];
    }

    return world.shadows.value.filter((shadow) => shadow.receiverId === receiverId);
  });
}

// Track DOM element position and sync it as the entity's Position component
export function useTrackPosition (
  entityId: EntityId,
  elementRef: Ref<HTMLElement | undefined>,
  surface: SurfaceKind,
  depth: number = 0,
) {
  const world = useWorld();
  const bounds = useNormalizedBounds(elementRef);

  if (!world) {
    return;
  }

  // Extract SVG silhouette and upgrade ShadowCaster to use it
  const silhouette = useSvgSilhouette(elementRef);

  watch(silhouette, (hull) => {
    if (3 <= hull.length && world.stores.shadowCaster.has(entityId)) {
      const existing = world.stores.shadowCaster.get(entityId);

      if (!existing) {
        return;
      }

      world.stores.shadowCaster.set(entityId, {
        ...existing,
        silhouette: SilhouetteShape.Custom,
        customPath: hull.map(([
          px,
          py,
        ]) => `${px},${py}`).join(' '),
      });
    }
  });

  watch(bounds, (value) => {
    if (value) {
      const position: Position = {
        ...value,
        depth,
        surface,
      };

      world.stores.position.set(entityId, position);
    }
  }, {
    immediate: true,
  });
}

export function useWorld (): World | undefined {
  return inject<World>(ROOM_WORLD_KEY);
}
