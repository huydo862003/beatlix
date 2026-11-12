use ecs::{EcsEntity, EcsWorld};

use crate::archetype::LightEmitterArchetype;
use crate::component::LightEmitterComponent;
use crate::types::Color;
use crate::world::LightWorld;

/// Spawn a light emitter entity
pub fn spawn_light_emitter(
  world: &mut LightWorld,
  color: Color,
  intensity: f32,
  radius: f32,
) -> EcsEntity<LightEmitterArchetype> {
  world.spawn(LightEmitterArchetype {
    emitter: LightEmitterComponent {
      color,
      intensity,
      radius,
    },
  })
}
