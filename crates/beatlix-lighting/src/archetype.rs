use super::component::{LightEmitterComponent, LightOccluderComponent, LightReceiverComponent};

/// Archetype for entities that emit light
#[ecs_macros::archetype]
pub struct LightEmitterArchetype {
  pub emitter: LightEmitterComponent,
}

/// Archetype for entities that block and receive light
#[ecs_macros::archetype]
pub struct LightBlockerArchetype {
  pub occluder: LightOccluderComponent,
  pub receiver: LightReceiverComponent,
}
