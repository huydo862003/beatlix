import type {
  Vec3,
} from '../math/vec3';

export enum LightType {
  Point = 'point',
  Directional = 'directional',
}

export enum PlaneOrientation {
  Horizontal = 'horizontal',
  Vertical = 'vertical',
}

export enum SilhouetteShape {
  Rect = 'rect',
  Circle = 'circle',
  Custom = 'custom',
}

export enum SurfaceKind {
  Sill = 'sill',
  Floor = 'floor',
  Wall = 'wall',
  Window = 'window',
}

export type ComponentBag = {
  [K in keyof ComponentMap]?: ComponentMap[K];
};

export interface ComponentMap {
  position: Position;
  shadowCaster: ShadowCaster;
  shadowReceiver: ShadowReceiver;
  lightEmitter: LightEmitter;
  lightOccluder: LightOccluder;
}

export interface LightEmitter {
  color: string;
  intensity: number;
  radius: number;
  type: LightType;
  // 3D light direction [x, y, z] where z = depth into the room
  direction?: Vec3;
}

export interface LightOccluder {
  panes: [number, number, number, number][];
}

export interface Position {
  x: number;
  y: number;
  w: number;
  h: number;
  // z-depth from the window plane (0 = at window, positive = into room)
  depth: number;
  surface: SurfaceKind;
}

export interface ShadowCaster {
  elevation: number;
  silhouette: SilhouetteShape;
  customPath?: string;
}

export interface ShadowReceiver {
  plane: PlaneOrientation;
  // angle of the surface in radians (0 = flat floor, pi/2 = vertical wall)
  angle: number;
}

export function createLightEmitter (options: {
  color: string;
  intensity: number;
  radius: number;
  type?: LightType;
  direction?: Vec3;
}): ComponentBag {
  return {
    lightEmitter: {
      type: LightType.Point,
      ...options,
    },
  };
}

export function createLightOccluder (panes: LightOccluder['panes']): ComponentBag {
  return {
    lightOccluder: {
      panes,
    },
  };
}

export function createShadowCaster (
  elevation: number,
  silhouette: SilhouetteShape = SilhouetteShape.Rect,
): ComponentBag {
  return {
    shadowCaster: {
      elevation,
      silhouette,
    },
  };
}

export function createShadowReceiver (
  plane: PlaneOrientation,
  angle: number = 0,
): ComponentBag {
  return {
    shadowReceiver: {
      plane,
      angle,
    },
  };
}
