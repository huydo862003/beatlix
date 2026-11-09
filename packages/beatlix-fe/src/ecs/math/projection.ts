import type {
  Vec2,
  Vec3,
} from './vec3';

export interface Polygon {
  points: Vec2[];
}

export interface Rect {
  x: number;
  y: number;
  w: number;
  h: number;
}

export function computeGlowRadius (options: {
  intensity: number;
  baseRadius: number;
}): {
  radius: number;
  opacity: number;
} {
  return {
    radius: options.baseRadius * (1 + options.intensity),
    opacity: options.intensity * 0.15,
  };
}

export function projectPaneToFloor (options: {
  pane: Rect;
  windowBounds: Rect;
  lightDirection: Vec3;
  floorScreenY: number;
  floorVisibleDepth: number;
}): Polygon {
  const {
    pane, windowBounds, lightDirection, floorScreenY, floorVisibleDepth,
  } = options;

  const left = windowBounds.x + pane.x * windowBounds.w;
  const top = windowBounds.y + pane.y * windowBounds.h;
  const right = left + pane.w * windowBounds.w;
  const bottom = top + pane.h * windowBounds.h;

  const shared = {
    lightDirection,
    floorScreenY,
    floorVisibleDepth,
  };

  return {
    points: [
      projectPointToFloor({
        windowPoint: [
          left,
          top,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          right,
          top,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          right,
          bottom,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          left,
          bottom,
        ],
        ...shared,
      }),
    ],
  };
}

export function projectPointToFloor (options: {
  windowPoint: Vec2;
  lightDirection: Vec3;
  floorScreenY: number;
  floorVisibleDepth: number;
}): Vec2 {
  const {
    windowPoint, lightDirection, floorScreenY, floorVisibleDepth,
  } = options;
  const [
    lightX,
    lightY,
    lightZ,
  ] = lightDirection;

  if (lightY === 0) {
    return windowPoint;
  }

  const timeToFloor = (floorScreenY - windowPoint[1]) / lightY;
  const floorX = windowPoint[0] + lightX * timeToFloor;
  const floorZ = lightZ * timeToFloor;
  const depthOnScreen = floorZ * floorVisibleDepth;

  return [
    floorX,
    floorScreenY + depthOnScreen,
  ];
}

// Project a shadow onto the floor using either a convex hull silhouette or bounding box
export function projectShadowToFloor (options: {
  objectBounds: Rect;
  lightDirection: Vec3;
  floorScreenY: number;
  floorVisibleDepth: number;
  customPath?: string;
}): Polygon {
  const {
    objectBounds, lightDirection, floorScreenY, floorVisibleDepth, customPath,
  } = options;

  const shared = {
    lightDirection,
    floorScreenY,
    floorVisibleDepth,
  };

  // Use convex hull silhouette if available
  if (customPath) {
    const hullPoints = customPath.split(' ').map((pair) => {
      const [
        nx,
        ny,
      ] = pair.split(',').map(Number);

      // Convert normalized hull coords (0-1 within object) to scene coords
      return [
        objectBounds.x + nx * objectBounds.w,
        objectBounds.y + ny * objectBounds.h,
      ] as Vec2;
    });

    return {
      points: hullPoints.map((point) => projectPointToFloor({
        windowPoint: point,
        ...shared,
      })),
    };
  }

  // Fallback to bounding box
  const left = objectBounds.x;
  const top = objectBounds.y;
  const right = objectBounds.x + objectBounds.w;
  const bottom = objectBounds.y + objectBounds.h;

  return {
    points: [
      projectPointToFloor({
        windowPoint: [
          left,
          top,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          right,
          top,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          right,
          bottom,
        ],
        ...shared,
      }),
      projectPointToFloor({
        windowPoint: [
          left,
          bottom,
        ],
        ...shared,
      }),
    ],
  };
}
