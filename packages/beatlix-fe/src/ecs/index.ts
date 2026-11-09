export {
  EntityCategory,
  defineEntity,
} from './entities';
export type {
  EntityDefinition,
  EntityId,
} from './entities';

export {
  LightType,
  PlaneOrientation,
  SilhouetteShape,
  SurfaceKind,
  createLightEmitter,
  createLightOccluder,
  createShadowCaster,
  createShadowReceiver,
} from './components';
export type {
  ComponentBag,
  ComponentMap,
  LightEmitter,
  LightOccluder,
  Position,
  ShadowCaster,
  ShadowReceiver,
} from './components';

export type {
  FloorLightPatch,
  FloorShadow,
  VisibilityResult,
  WindowGlow,
} from './effects';

export {
  createWorld,
} from './world';
export type {
  World,
} from './world';

export {
  ROOM_WORLD_KEY,
  provideRoomContainer,
  useLightPoolsOnSurface,
  useNormalizedBounds,
  useRoomEntity,
  useShadowsOnSurface,
  useTrackPosition,
  useWorld,
} from './vue/useRoomEntity';
