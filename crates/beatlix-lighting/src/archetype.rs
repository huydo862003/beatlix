use super::component::{
  LightEmitterComponent, LightOccluderComponent, LightReceiverComponent, TransformComponent,
};

/// Archetype for entities that emit light
#[ecs_macros::archetype]
pub struct LightEmitterArchetype {
  pub transform: TransformComponent,
  pub emitter: LightEmitterComponent,
}

/// Archetype for entities that block and receive light
#[ecs_macros::archetype]
pub struct LightBlockerArchetype {
  pub transform: TransformComponent,
  pub occluder: LightOccluderComponent,
  pub receiver: LightReceiverComponent,
}
