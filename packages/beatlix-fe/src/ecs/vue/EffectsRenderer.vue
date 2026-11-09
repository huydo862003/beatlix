<script setup lang="ts">
import {
  computed, inject,
} from 'vue';
import type {
  World,
} from '../world';
import {
  ROOM_WORLD_KEY,
} from './useRoomEntity';

defineOptions({
  name: 'RoomEffectsRenderer',
});

const world = inject<World>(ROOM_WORLD_KEY);

function toSvgPoints (points: [number, number][]): string {
  return points.map(([
    px,
    py,
  ]) => `${px * 100},${py * 100}`).join(' ');
}

const visibility = computed(() => world?.visibility.value);

// Get floor position for clipping (light/shadows only on the floor)
const floorPosition = computed(() => {
  if (!world) {
    return undefined;
  }
  const floorPosition_ = world.stores.position.get('floor');

  return floorPosition_;
});
</script>

<template>
  <svg
    v-if="visibility"
    viewBox="0 0 100 100"
    class="absolute inset-0 w-full h-full"
    preserveAspectRatio="none"
  >
    <defs>
      <radialGradient
        v-for="glow in visibility.glows"
        :id="`glow-${glow.emitterId}`"
        :key="`glow-def-${glow.emitterId}`"
      >
        <stop
          offset="0%"
          :stop-color="glow.color"
          :stop-opacity="glow.opacity"
        />
        <stop
          offset="100%"
          :stop-color="glow.color"
          stop-opacity="0"
        />
      </radialGradient>

      <!-- Clip to floor zone only -->
      <clipPath
        v-if="floorPosition"
        id="floor-clip"
      >
        <rect
          :x="0"
          :y="floorPosition.y * 100"
          width="100"
          :height="(1 - floorPosition.y) * 100"
        />
      </clipPath>
    </defs>

    <!-- Ambient glow radiating from the window -->
    <ellipse
      v-for="glow in visibility.glows"
      :key="`glow-${glow.emitterId}`"
      :cx="glow.centerX * 100"
      :cy="glow.centerY * 100"
      :rx="glow.radius * 80"
      :ry="glow.radius * 70"
      :fill="`url(#glow-${glow.emitterId})`"
    />

    <!-- Light patches clipped to floor -->
    <g clip-path="url(#floor-clip)">
      <polygon
        v-for="(patch, patchIndex) in visibility.lightPatches"
        :key="`light-${patch.emitterId}-${patchIndex}`"
        :points="toSvgPoints(patch.polygon.points)"
        :fill="patch.color"
        :opacity="patch.opacity"
      />

      <polygon
        v-for="(shadow, shadowIndex) in visibility.shadows"
        :key="`shadow-${shadow.casterId}-${shadowIndex}`"
        :points="toSvgPoints(shadow.polygon.points)"
        fill="#000"
        :opacity="shadow.opacity"
      />
    </g>

    <!-- Distance darkening: room gets darker further from window -->
    <defs>
      <linearGradient
        id="distance-dark"
        x1="0"
        y1="0"
        x2="0"
        y2="1"
      >
        <stop
          offset="0%"
          stop-color="#000"
          stop-opacity="0"
        />
        <stop
          offset="60%"
          stop-color="#000"
          stop-opacity="0.15"
        />
        <stop
          offset="100%"
          stop-color="#000"
          stop-opacity="0.35"
        />
      </linearGradient>
    </defs>
    <rect
      width="100"
      height="100"
      fill="url(#distance-dark)"
    />
  </svg>
</template>
