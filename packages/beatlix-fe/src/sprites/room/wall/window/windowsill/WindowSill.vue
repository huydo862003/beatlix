<script setup lang="ts">
import {
  type Component, useTemplateRef,
} from 'vue';
import DefaultSill from './assets/windowsill.svg?component';
import {
  EntityCategory,
  PlaneOrientation,
  SilhouetteShape,
  SurfaceKind,
  createShadowCaster,
  createShadowReceiver,
  defineEntity,
  useRoomEntity,
  useTrackPosition,
} from '@/ecs';

defineOptions({
  name: 'RoomWindowSill',
});

const {
  sill = DefaultSill,
} = defineProps<{
  /** SVG component for the sill */
  sill?: Component;
}>();

const elementRef = useTemplateRef<HTMLElement>('element');

useRoomEntity(defineEntity(
  'window-sill',
  EntityCategory.Structure,
  createShadowCaster(0.1, SilhouetteShape.Rect),
  createShadowReceiver(PlaneOrientation.Horizontal),
));

useTrackPosition('window-sill', elementRef, SurfaceKind.Sill);
</script>

<template>
  <div
    ref="element"
    class="relative"
  >
    <component
      :is="sill"
      class="w-full"
    />
    <div class="absolute inset-x-0 bottom-[var(--room-sill-anchor)] flex items-end justify-between px-[1%]">
      <div class="flex items-end gap-2">
        <slot name="left" />
      </div>
      <slot name="center" />
      <div class="flex items-end gap-2">
        <slot name="right" />
      </div>
    </div>
  </div>
</template>
