<script setup lang="ts">
import {
  useTemplateRef,
} from 'vue';
import CandleSvg from './assets/candle.svg?component';
import CandleBlownSvg from './assets/candle-blown.svg?component';
import {
  EntityCategory,
  SilhouetteShape,
  SurfaceKind,
  createLightEmitter,
  createShadowCaster,
  defineEntity,
  useRoomEntity,
  useTrackPosition,
} from '@/ecs';

defineOptions({
  name: 'RoomCandle',
});

const {
  blown = false,
} = defineProps<{
  /** whether the candle flame is blown out */
  blown?: boolean;
}>();

const elementRef = useTemplateRef<HTMLElement>('element');

useRoomEntity(defineEntity('candle', EntityCategory.Placeable, createShadowCaster(0.8, SilhouetteShape.Rect)));
useTrackPosition('candle', elementRef, SurfaceKind.Sill);

if (!blown) {
  useRoomEntity(defineEntity('candle-flame', EntityCategory.Light, createLightEmitter({
    color: '#E8A030',
    intensity: 0.4,
    radius: 0.15,
  })));
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
