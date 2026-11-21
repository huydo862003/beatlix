<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import PlantSvg from './assets/plant.svg?component';
import {
  useSceneBlocker,
} from '@/lighting/scene';

defineOptions({
  name: 'RoomPlant',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useSceneBlocker('plant', elementRef, {
  depth: 0.1,
});
</script>

<template>
  <div ref="element">
    <PlantSvg class="w-full h-auto" />
  </div>
</template>
