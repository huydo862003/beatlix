import type {
  LightEmitter, LightOccluder, Position, ShadowCaster,
} from '../components/types';
import {
  LightType,
} from '../components/types';
import type {
  EntityId,
} from '../entities/types';
import type {
  Polygon,
} from '../math/projection';
import {
  computeGlowRadius,
  projectPaneToFloor,
  projectShadowToFloor,
} from '../math/projection';
import type {
  Vec3,
} from '../math/vec3';

export interface FloorLightPatch {
  emitterId: EntityId;
  polygon: Polygon;
  color: string;
  opacity: number;
}

export interface FloorShadow {
  casterId: EntityId;
  polygon: Polygon;
  opacity: number;
}

export interface VisibilityResult {
  lightPatches: FloorLightPatch[];
  shadows: FloorShadow[];
  glows: WindowGlow[];
}

export interface WindowGlow {
  emitterId: EntityId;
  centerX: number;
  centerY: number;
  radius: number;
  color: string;
  opacity: number;
}

// Light from upper-right: x=right shift, y=downward, z=into room
const DEFAULT_DIRECTION: Vec3 = [
  -0.12,
  1,
  0.8,
];

const FLOOR_VISIBLE_DEPTH = 0.25;

export function computeVisibility (options: {
  lights: {
    id: EntityId;
    lightEmitter: LightEmitter;
  }[];
  occluders: {
    id: EntityId;
    position: Position;
    lightOccluder: LightOccluder;
  }[];
  casters: {
    id: EntityId;
    position: Position;
    shadowCaster: ShadowCaster;
  }[];
  receivers: {
    id: EntityId;
    position: Position;
  }[];
}): VisibilityResult {
  const {
    lights, occluders, casters, receivers,
  } = options;

  const lightPatches: FloorLightPatch[] = [];
  const shadows: FloorShadow[] = [];
  const glows: WindowGlow[] = [];

  for (const light of lights) {
    const direction = light.lightEmitter.direction ?? DEFAULT_DIRECTION;

    if (light.lightEmitter.type === LightType.Directional) {
      computeDirectionalLight({
        light,
        direction,
        occluders,
        casters,
        receivers,
        lightPatches,
        shadows,
        glows,
      });
    }

    if (light.lightEmitter.type === LightType.Point) {
      computePointGlow({
        light,
        casters,
        glows,
      });
    }
  }

  return {
    lightPatches,
    shadows,
    glows,
  };
}

function computeDirectionalLight (context: {
  light: {
    id: EntityId;
    lightEmitter: LightEmitter;
  };
  direction: Vec3;
  occluders: {
    id: EntityId;
    position: Position;
    lightOccluder: LightOccluder;
  }[];
  casters: {
    id: EntityId;
    position: Position;
    shadowCaster: ShadowCaster;
  }[];
  receivers: {
    id: EntityId;
    position: Position;
  }[];
  lightPatches: FloorLightPatch[];
  shadows: FloorShadow[];
  glows: WindowGlow[];
}) {
  const {
    light, direction, occluders, casters, receivers, lightPatches, shadows, glows,
  } = context;

  for (const occluder of occluders) {
    const windowBounds = {
      x: occluder.position.x,
      y: occluder.position.y,
      w: occluder.position.w,
      h: occluder.position.h,
    };

    for (const receiver of receivers) {
      const floorScreenY = receiver.position.y;

      // Light passes through each pane opening
      for (const pane of occluder.lightOccluder.panes) {
        const patch = projectPaneToFloor({
          pane: {
            x: pane[0],
            y: pane[1],
            w: pane[2],
            h: pane[3],
          },
          windowBounds,
          lightDirection: direction,
          floorScreenY,
          floorVisibleDepth: FLOOR_VISIBLE_DEPTH,
        });

        lightPatches.push({
          emitterId: light.id,
          polygon: patch,
          color: light.lightEmitter.color,
          opacity: light.lightEmitter.intensity * 0.15,
        });
      }

      // Objects on the sill block some light
      for (const caster of casters) {
        if (caster.shadowCaster.elevation <= 0) {
          continue;
        }

        const shadow = projectShadowToFloor({
          objectBounds: {
            x: caster.position.x,
            y: caster.position.y,
            w: caster.position.w,
            h: caster.position.h,
          },
          lightDirection: direction,
          floorScreenY,
          floorVisibleDepth: FLOOR_VISIBLE_DEPTH,
          customPath: caster.shadowCaster.customPath,
        });

        shadows.push({
          casterId: caster.id,
          polygon: shadow,
          opacity: 0.3 * caster.shadowCaster.elevation,
        });
      }
    }

    // Ambient glow around the window
    const {
      radius, opacity,
    } = computeGlowRadius({
      intensity: light.lightEmitter.intensity,
      baseRadius: light.lightEmitter.radius,
    });

    glows.push({
      emitterId: light.id,
      centerX: occluder.position.x + occluder.position.w / 2,
      centerY: occluder.position.y + occluder.position.h / 2,
      radius,
      color: light.lightEmitter.color,
      opacity,
    });
  }
}

function computePointGlow (context: {
  light: {
    id: EntityId;
    lightEmitter: LightEmitter;
  };
  casters: {
    id: EntityId;
    position: Position;
    shadowCaster: ShadowCaster;
  }[];
  glows: WindowGlow[];
}) {
  const {
    light, casters, glows,
  } = context;

  const matchingCaster = casters.find(
    (caster) => caster.id.startsWith(light.id.replace('-flame', '')),
  );

  if (matchingCaster) {
    const {
      radius, opacity,
    } = computeGlowRadius({
      intensity: light.lightEmitter.intensity,
      baseRadius: light.lightEmitter.radius,
    });

    glows.push({
      emitterId: light.id,
      centerX: matchingCaster.position.x + matchingCaster.position.w / 2,
      centerY: matchingCaster.position.y,
      radius,
      color: light.lightEmitter.color,
      opacity,
    });
  }
}
