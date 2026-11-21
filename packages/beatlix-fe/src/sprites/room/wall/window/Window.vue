<script setup lang="ts">
import {
  type Component, useTemplateRef,
} from 'vue';
import DefaultFrame from './frame/frame.svg?component';
import WindowSill from './windowsill/WindowSill.vue';
import {
  useSceneBlocker,
} from '@/lighting/scene';

defineOptions({
  name: 'RoomWindow',
});

const {
  /** SVG component for the window frame */
  frame = DefaultFrame,
} = defineProps<{
  /** SVG component for the window frame */
  frame?: Component;
}>();

const frameRef = useTemplateRef<HTMLElement>('frameElement');

useSceneBlocker('window-frame', frameRef, {
  depth: 0,
});
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
