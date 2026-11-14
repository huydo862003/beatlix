import {
  type InjectionKey, type Ref,
  effectScope, inject, provide, ref, watchEffect,
} from 'vue';
import {
  computeLighting, loadLighting,
} from '@beatlix/lighting';
import type {
  LightingResult, SceneInput,
} from '@beatlix/lighting';

const LIGHTING_KEY: InjectionKey<Ref<LightingResult>> = Symbol('room-lighting');

export function injectLighting (): Ref<LightingResult> | undefined {
  return inject(LIGHTING_KEY);
}

export function provideLighting (sceneInput: Ref<SceneInput>): void {
  const result = ref<LightingResult>({
    shadows: [],
  });
  const scope = effectScope();

  loadLighting().then(() => {
    scope.run(() => {
      watchEffect(() => {
        result.value = computeLighting(sceneInput.value) ?? {
          shadows: [],
        };
      });
    });
  });

  provide(LIGHTING_KEY, result as Ref<LightingResult>);
}
