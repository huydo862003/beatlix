<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import PlantSvg from './assets/plant.svg?component';
import {
  EntityCategory,
  SilhouetteShape,
  SurfaceKind,
  createShadowCaster,
  defineEntity,
  useRoomEntity,
  useTrackPosition,
} from '@/ecs';

defineOptions({
  name: 'RoomPlant',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useRoomEntity(defineEntity('plant', EntityCategory.Placeable, createShadowCaster(0.6, SilhouetteShape.Circle)));
useTrackPosition('plant', elementRef, SurfaceKind.Sill);
</script>

<template>
  <div ref="element">
    <PlantSvg class="w-full h-auto" />
  </div>
</template>
