<script setup lang="ts">
import {
  type Component,
} from 'vue';
import DefaultSill from './assets/windowsill.svg?component';

defineOptions({
  name: 'RoomWindowSill',
});

const {
  /** SVG component for the sill */
  sill = DefaultSill,
} = defineProps<{
  /** SVG component for the sill */
  sill?: Component;
}>();
</script>

<template>
  <div class="relative">
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
