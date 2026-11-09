<script setup lang="ts">
import {
  provide, useTemplateRef,
} from 'vue';
import {
  ROOM_WORLD_KEY, createWorld, provideRoomContainer,
} from '@/ecs';

const world = createWorld();
const containerRef = useTemplateRef<HTMLElement>('roomContainer');

provide(ROOM_WORLD_KEY, world);
provideRoomContainer(containerRef);
</script>

<template>
  <div
    ref="roomContainer"
    class="relative w-full h-full overflow-hidden"
  >
    <div class="absolute inset-x-0 top-0 bottom-[var(--room-floor-height)]">
      <slot name="wall-scene" />
    </div>

    <div class="absolute inset-x-0 bottom-0 h-[var(--room-floor-height)] overflow-hidden">
      <slot name="floor" />
    </div>

    <div class="absolute inset-0 pointer-events-none z-10">
      <slot name="effects" />
    </div>
  </div>
</template>
