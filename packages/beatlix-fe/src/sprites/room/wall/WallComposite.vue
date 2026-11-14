<script setup lang="ts">
import WallSvg from './wall.svg?component';

defineOptions({
  name: 'RoomWallComposite',
});
</script>

<template>
  <div class="relative w-full h-full overflow-hidden">
    <WallSvg
      class="absolute inset-0 w-full h-full"
      preserveAspectRatio="none"
    />

    <div class="absolute inset-0 flex items-end justify-center pb-[var(--room-sill-gap)]">
      <div class="relative w-[var(--room-scene-width)]">
        <slot />
      </div>
    </div>
  </div>
</template>
