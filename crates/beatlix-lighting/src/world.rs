use ecs::EcsStorage;
use glam::{
  Mat4, Vec2, Vec3,
  camera::rh::{proj::opengl, view},
};

use super::vertex_pool::VertexPool;

#[ecs_macros::world]
pub struct LightWorld {
  storage: EcsStorage,
  pub vertex_pool: VertexPool,
  pub camera: Camera,
}

impl LightWorld {
  pub fn new(camera: Camera) -> Self {
    Self {
      storage: EcsStorage::new(),
      vertex_pool: VertexPool::new(),
      camera,
    }
  }
}

/// Camera that defines how 3D world maps to 2D screen
#[derive(Debug, Clone, Copy)]
pub struct Camera {
  /// View-projection matrix: transforms world space to screen space
  pub view_projection: Mat4,
  /// Inverse for unprojecting screen points back to world
  pub inverse_view_projection: Mat4,
}

impl Camera {
  /// Create an oblique projection camera for a room scene
  /// eye: camera position in world space
  /// target: point the camera looks at
  /// up: up direction (usually Vec3::Y)
  /// width/height: viewport size in pixels
  pub fn new_oblique(eye: Vec3, target: Vec3, up: Vec3, width: f32, height: f32) -> Self {
    let view = view::look_at_mat4(eye, target, up);
    let projection = opengl::orthographic(
      -width / 2.0,
      width / 2.0,
      -height / 2.0,
      height / 2.0,
      0.1,
      1000.0,
    );
    let view_projection = projection * view;
    let inverse_view_projection = view_projection.inverse();

    Self {
      view_projection,
      inverse_view_projection,
    }
  }

  /// Project a 3D world point to 2D screen coordinates
  #[inline]
  pub fn project(&self, world_point: Vec3) -> Vec2 {
    let clip = self.view_projection * world_point.extend(1.0);
    Vec2::new(clip.x / clip.w, clip.y / clip.w)
  }

  /// Project a 3D direction to 2D screen direction (no translation)
  #[inline]
  pub fn project_direction(&self, world_direction: Vec3) -> Vec2 {
    let projected = self.view_projection.transform_vector3(world_direction);
    Vec2::new(projected.x, projected.y).normalize_or_zero()
  }
}
