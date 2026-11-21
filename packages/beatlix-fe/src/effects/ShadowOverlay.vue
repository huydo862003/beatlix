<script setup lang="ts">
import {
  injectLighting,
} from '@/lighting/composables';

defineOptions({
  name: 'ShadowOverlay',
});

const lighting = injectLighting();

function convertColorToCssRgba (color: [number, number, number, number], intensity: number): string {
  const red = Math.round(color[0] * 255);
  const green = Math.round(color[1] * 255);
  const blue = Math.round(color[2] * 255);

  return `rgba(${red},${green},${blue},${intensity})`;
}

function convertVerticesToSvgPoints (vertices: [number, number][]): string {
  return vertices.map(([
    pointX,
    pointY,
  ]) => `${(pointX * 100).toFixed(2)},${(pointY * 100).toFixed(2)}`).join(' ');
}
</script>

<template>
  <svg
    v-if="lighting"
    viewBox="0 0 100 100"
    class="absolute inset-0 w-full h-full"
    preserveAspectRatio="none"
    aria-hidden="true"
  >
    <polygon
      v-for="(shadow, index) in lighting.shadows"
      :key="index"
      :points="convertVerticesToSvgPoints(shadow.vertices)"
      :fill="convertColorToCssRgba(shadow.color, shadow.intensity)"
    />

    <defs>
      <linearGradient
        id="room-depth-gradient"
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
          stop-opacity="0.12"
        />
        <stop
          offset="100%"
          stop-color="#000"
          stop-opacity="0.32"
        />
      </linearGradient>
    </defs>
    <rect
      width="100"
      height="100"
      fill="url(#room-depth-gradient)"
    />
  </svg>
</template>
