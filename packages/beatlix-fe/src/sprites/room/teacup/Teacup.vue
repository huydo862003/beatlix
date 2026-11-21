<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import TeacupSvg from './assets/teacup.svg?component';
import {
  useSceneBlocker,
} from '@/lighting/scene';

defineOptions({
  name: 'RoomTeacup',
});

const elementRef = useTemplateRef<HTMLElement>('element');

useSceneBlocker('teacup', elementRef, {
  depth: 0.05,
});
</script>

<template>
  <div ref="element">
    <TeacupSvg class="w-full h-auto" />
  </div>
</template>
