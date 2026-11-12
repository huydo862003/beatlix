use ecs::EcsStorage;

use super::vertex_pool::VertexPool;

#[ecs_macros::world]
pub struct LightWorld {
  storage: EcsStorage,
  pub vertex_pool: VertexPool,
}
