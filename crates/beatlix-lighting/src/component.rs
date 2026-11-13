use glam::Vec3;

use super::types::Color;

/// Handle into a VertexPool, stored in components
#[derive(Debug, Clone, Copy, Default)]
pub struct VertexSlice {
  pub(crate) start: u32,
  pub(crate) count: u16,
}

/// 3D spatial transform
/// Position is in world space, direction is normalized
#[ecs_macros::component]
#[derive(Debug, Clone, Copy)]
pub struct TransformComponent {
  pub position: Vec3,
  pub direction: Vec3,
}

/// Light emission properties
/// Cone angle: half-angle of the spotlight in radians
#[ecs_macros::component]
#[derive(Debug, Clone, Copy)]
pub struct LightEmitterComponent {
  pub cone_angle: f32,
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
