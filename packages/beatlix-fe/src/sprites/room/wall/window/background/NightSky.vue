<script setup lang="ts">
import {
  LightType, createLightEmitter, defineEntity, useRoomEntity,
  EntityCategory,
} from '@/ecs';

defineOptions({
  name: 'RoomNightSky',
});

useRoomEntity(defineEntity(
  'moon',
  EntityCategory.Light,
  createLightEmitter({
    color: '#EDD9A3',
    intensity: 0.8,
    radius: 1.5,
    type: LightType.Directional,
    direction: [
      -0.12,
      1,
      0.8,
    ],
  }),
));
</script>

<template>
  <div class="absolute inset-0 bg-[#1D2057]">
    <slot name="moon" />
    <slot name="weather" />
    <slot name="skyline" />
  </div>
</template>
