use ecs::{EcsEntity, EcsWorld};
use glam::Vec3;

use crate::archetype::LightEmitterArchetype;
use crate::component::{LightEmitterComponent, TransformComponent};
use crate::types::Color;
use crate::world::LightWorld;

/// Spawn a spotlight entity
/// Position: (x, y) is world position, z is height above surface
/// Direction: where the light points (will be normalized)
/// Cone angle: half-angle of the spotlight in radians
pub fn spawn_light_emitter(
  world: &mut LightWorld,
  position: Vec3,
  direction: Vec3,
  cone_angle: f32,
  color: Color,
  intensity: f32,
  radius: f32,
) -> EcsEntity<LightEmitterArchetype> {
  world.spawn(LightEmitterArchetype {
    transform: TransformComponent {
      position,
      direction: direction.normalize_or_zero(),
    },
    emitter: LightEmitterComponent {
      cone_angle,
      color,
      intensity,
      radius,
    },
  })
}
