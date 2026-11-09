<script setup lang="ts">
import {
  type Component, useTemplateRef,
} from 'vue';
import DefaultFrame from './frame/frame.svg?component';
import WindowSill from './windowsill/WindowSill.vue';
import {
  EntityCategory,
  SilhouetteShape,
  SurfaceKind,
  createLightOccluder,
  createShadowCaster,
  defineEntity,
  useRoomEntity,
  useTrackPosition,
} from '@/ecs';

defineOptions({
  name: 'RoomWindow',
});

const {
  frame = DefaultFrame,
} = defineProps<{
  /** SVG component for the window frame */
  frame?: Component;
}>();

const frameRef = useTemplateRef<HTMLElement>('frameElement');

useRoomEntity(defineEntity(
  'window-frame',
  EntityCategory.Structure,
  createShadowCaster(0, SilhouetteShape.Custom),
  createLightOccluder([
    [
      0.016,
      0.021,
      0.476,
      0.468,
    ],
    [
      0.508,
      0.021,
      0.476,
      0.468,
    ],
    [
      0.016,
      0.511,
      0.476,
      0.468,
    ],
    [
      0.508,
      0.511,
      0.476,
      0.468,
    ],
  ]),
));

useTrackPosition('window-frame', frameRef, SurfaceKind.Window);
</script>

<template>
  <div class="relative">
    <div
      ref="frameElement"
      class="relative overflow-hidden rounded-[2%] max-h-[50dvh]"
    >
      <div class="absolute inset-0">
        <slot name="background" />
      </div>

      <component
        :is="frame"
        class="relative w-full"
      />
    </div>

    <div class="-mt-[3%] relative z-10">
      <slot name="sill">
        <WindowSill>
          <template #left>
            <slot name="sill-left" />
          </template>
          <template #center>
            <slot name="sill-center" />
          </template>
          <template #right>
            <slot name="sill-right" />
          </template>
        </WindowSill>
      </slot>
    </div>
  </div>
</template>
