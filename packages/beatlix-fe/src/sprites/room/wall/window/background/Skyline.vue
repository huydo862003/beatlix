<script setup lang="ts">
import {
  type Component,
} from 'vue';
import DefaultSkyline from './night-city-silhouette.svg?component';

defineOptions({
  name: 'RoomSkyline',
});

const {
  skyline = DefaultSkyline,
  height = 35,
} = defineProps<{
  /** SVG component to tile as the skyline */
  skyline?: Component;
  /** height of the skyline band as % of window height */
  height?: number;
}>();
</script>

<template>
  <div
    class="absolute bottom-0 w-full flex items-end overflow-hidden"
    :style="{
      height: `${height}%`,
    }"
  >
    <component
      :is="skyline"
      class="h-full shrink-0"
    />
    <component
      :is="skyline"
      class="h-full shrink-0"
    />
    <component
      :is="skyline"
      class="h-full shrink-0"
    />
    <component
      :is="skyline"
      class="h-full shrink-0"
    />
  </div>
</template>
