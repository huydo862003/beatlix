use super::types::Color;

/// Handle into a VertexPool, stored in components
#[derive(Debug, Clone, Copy, Default)]
pub struct VertexSlice {
  pub(crate) start: u32,
  pub(crate) count: u16,
}

/// Components that are capable of emitting lights
#[ecs_macros::component]
#[derive(Debug, Clone, Copy)]
pub struct LightEmitterComponent {
  pub color: Color,
  pub intensity: f32,
  pub radius: f32,
}

/// Components that are capable of blocking lights
#[ecs_macros::component]
#[derive(Debug, Clone, Copy)]
pub struct LightOccluderComponent {
  pub vertices: VertexSlice,
}

/// Components that are capable of receiving lights
#[ecs_macros::component]
#[derive(Debug, Clone, Copy)]
pub struct LightReceiverComponent {
  pub vertices: VertexSlice,
}
