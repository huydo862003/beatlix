<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import PlantSvg from './assets/plant.svg?component';
import {
  useShadowCaster,
} from '@/components/room-layout/renderer';

defineOptions({
  name: 'RoomPlant',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useShadowCaster('plant', elementRef, {
  depth: 0.1,
});
</script>

<template>
  <div ref="element">
    <PlantSvg class="w-full h-auto" />
  </div>
</template>
