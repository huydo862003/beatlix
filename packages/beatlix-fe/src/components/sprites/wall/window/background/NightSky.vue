<script setup lang="ts">
import {
  useFixedLightSource,
} from '@/components/room-layout/renderer';

defineOptions({
  name: 'RoomNightSky',
});

useFixedLightSource('moon', {
  color: [
    0.93,
    0.85,
    0.64,
    1.0,
  ],
  intensity: 0.8,
  radius: 1.5,
  coneAngle: Math.PI / 2.5,
  direction: [
    -0.12,
    -1,
    0.8,
  ],
  depth: -1,
});
</script>

<template>
  <div class="absolute inset-0 bg-[#1D2057]">
    <slot name="moon" />
    <slot name="weather" />
    <slot name="skyline" />
  </div>
</template>
