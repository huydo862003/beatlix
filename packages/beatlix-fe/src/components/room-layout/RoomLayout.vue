<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import {
  LightingOverlay, provideRenderer,
} from './renderer';

defineOptions({
  name: 'RoomLayout',
});

const containerRef = useTemplateRef<HTMLElement>('container');

provideRenderer(containerRef);
</script>

<template>
  <div
    ref="container"
    class="relative w-full h-full overflow-hidden"
  >
    <div class="absolute inset-x-0 top-0 bottom-[var(--room-floor-height)]">
      <slot name="wall" />
    </div>

    <div class="absolute inset-x-0 bottom-0 h-[var(--room-floor-height)] overflow-hidden">
      <slot name="floor" />
    </div>

    <div class="absolute inset-0 pointer-events-none z-10">
      <LightingOverlay />
    </div>
  </div>
</template>
