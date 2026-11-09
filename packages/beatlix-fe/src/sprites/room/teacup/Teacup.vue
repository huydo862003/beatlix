<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import TeacupSvg from './assets/teacup.svg?component';
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
  name: 'RoomTeacup',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useRoomEntity(defineEntity('teacup', EntityCategory.Placeable, createShadowCaster(0.3, SilhouetteShape.Circle)));
useTrackPosition('teacup', elementRef, SurfaceKind.Sill);
</script>

<template>
  <div ref="element">
    <TeacupSvg />
  </div>
</template>
