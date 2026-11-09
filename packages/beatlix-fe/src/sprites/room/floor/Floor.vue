<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import FloorSvg from './assets/floor.svg?component';
import {
  EntityCategory,
  PlaneOrientation,
  SurfaceKind,
  createShadowReceiver,
  defineEntity,
  useRoomEntity,
  useTrackPosition,
} from '@/ecs';

defineOptions({
  name: 'RoomFloor',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useRoomEntity(defineEntity('floor', EntityCategory.Surface, createShadowReceiver(PlaneOrientation.Horizontal)));
useTrackPosition('floor', elementRef, SurfaceKind.Floor, 1);
</script>

<template>
  <div
    ref="element"
    class="w-full h-full"
  >
    <FloorSvg class="w-full h-full" />
  </div>
</template>
