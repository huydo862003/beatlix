<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import CandleSvg from './assets/candle.svg?component';
import CandleBlownSvg from './assets/candle-blown.svg?component';
import {
  useSceneBlocker, useSceneEmitter,
} from '@/lighting/scene';

defineOptions({
  name: 'RoomCandle',
});

const {
  /** Whether the candle flame is blown out */
  blown = false,
} = defineProps<{
  /** Whether the candle flame is blown out */
  blown?: boolean;
}>();

const elementRef = useTemplateRef<HTMLElement>('element');

useSceneBlocker('candle', elementRef, {
  depth: 0.1,
});

if (!blown) {
  useSceneEmitter('candle-flame', {
    color: [
      1.0,
      0.63,
      0.19,
      1.0,
    ],
    intensity: 0.4,
    radius: 0.15,
    coneAngle: Math.PI,
    direction: [
      0,
      1,
      0,
    ],
    depth: 0.15,
  }, elementRef);
}
</script>

<template>
  <div ref="element">
    <CandleBlownSvg
      v-if="blown"
      class="w-full h-auto"
    />
    <CandleSvg
      v-else
      class="w-full h-auto"
    />
  </div>
</template>
