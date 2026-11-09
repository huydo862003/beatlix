<script setup lang="ts">
import {
  useRouter,
} from 'vue-router';
import RoomLayout from '@/components/room/RoomLayout.vue';
import EffectsRenderer from '@/ecs/vue/EffectsRenderer.vue';
import Floor from '@/sprites/room/floor/Floor.vue';
import WallComposite from '@/sprites/room/wall/WallComposite.vue';
import Window from '@/sprites/room/wall/window/Window.vue';
import NightSky from '@/sprites/room/wall/window/background/NightSky.vue';
import Skyline from '@/sprites/room/wall/window/background/Skyline.vue';
import Candle from '@/sprites/room/candle/Candle.vue';
import Plant from '@/sprites/room/plant/Plant.vue';
import RainSvg from '@/sprites/room/wall/window/background/rain.svg?component';
import MoonSvg from '@/sprites/room/wall/window/background/moon.svg?component';

const router = useRouter();

function goToSignIn () {
  router.push('/sign-in');
}
</script>

<template>
  <div class="w-dvw h-dvh p-[var(--room-screen-gap)]">
    <div
      class="
        w-full h-full
        rounded-2xl overflow-hidden
        ring-1 ring-amethyst-smoke-700/50
        shadow-2xl
      "
    >
      <RoomLayout>
        <template #wall-scene>
          <WallComposite>
            <Window class="w-full">
              <template #background>
                <NightSky>
                  <template #moon>
                    <MoonSvg class="absolute top-[max(15%,4rem)] right-[8%] w-[28%]" />
                  </template>
                  <template #weather>
                    <RainSvg class="absolute inset-0 w-full h-full" />
                  </template>
                  <template #skyline>
                    <Skyline :height="35" />
                  </template>
                </NightSky>
              </template>
              <template #sill-left>
                <Plant class="w-[30%]" />
                <button
                  type="button"
                  class="w-[30%] cursor-pointer"
                  @click="goToSignIn"
                >
                  <Candle
                    blown
                    class="w-full"
                  />
                </button>
              </template>
            </Window>
          </WallComposite>
        </template>

        <template #floor>
          <Floor />
        </template>
        <template #effects>
          <EffectsRenderer />
        </template>
      </RoomLayout>
    </div>
  </div>
</template>
