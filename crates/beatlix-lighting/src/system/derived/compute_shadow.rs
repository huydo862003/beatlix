use ecs::EcsWorld;
use glam::{Vec2, Vec3};

use crate::Camera;
use crate::archetype::{LightBlockerArchetype, LightEmitterArchetype};
use crate::component::{LightEmitterComponent, LightOccluderComponent, TransformComponent};
use crate::types::{Color, Vertex2D};
use crate::world::LightWorld;

/// A shadow polygon in screen space, ready for rendering
#[derive(Debug)]
pub struct ShadowVolume {
  pub screen_vertices: Vec<Vertex2D>,
  pub color: Color,
  pub intensity: f32,
}

/// Compute all shadow volumes in the scene
/// Works in 3D world space, then projects results to screen space via camera
pub fn compute_shadows(world: &LightWorld) -> Vec<ShadowVolume> {
  let mut shadows = Vec::new();

  let Some(light_transforms) = world.component_slice::<LightEmitterArchetype, TransformComponent>()
  else {
    return shadows;
  };

  let Some(emitters) = world.component_slice::<LightEmitterArchetype, LightEmitterComponent>()
  else {
    return shadows;
  };

  let Some(blocker_transforms) =
    world.component_slice::<LightBlockerArchetype, TransformComponent>()
  else {
    return shadows;
  };

  let Some(occluders) = world.component_slice::<LightBlockerArchetype, LightOccluderComponent>()
  else {
    return shadows;
  };

  for (light_transform, emitter) in light_transforms.iter().zip(emitters.iter()) {
    let light_position = light_transform.position;

    for (blocker_transform, occluder) in blocker_transforms.iter().zip(occluders.iter()) {
      let occluder_vertices_2d = world.vertex_pool.get_polygon(occluder.vertices);

      // Lift 2D occluder vertices to 3D using the blocker's z position
      let occluder_z = blocker_transform.position.z;

      if let Some(shadow) = extrude_shadow_volume_3d(
        emitter,
        light_position,
        occluder_vertices_2d,
        occluder_z,
        &world.camera,
      ) {
        shadows.push(shadow);
      }
    }
  }

  shadows
}

/// 3D shadow volume extrusion projected to screen space
///
/// 1. Lift 2D occluder vertices to 3D at the occluder's z height
/// 2. Find silhouette edges (facing away from the light in screen space)
/// 3. Project each silhouette vertex away from the light in 3D
/// 4. Project all resulting vertices to screen space via camera
fn extrude_shadow_volume_3d(
  emitter: &LightEmitterComponent,
  light_position: Vec3,
  occluder_vertices_2d: &[Vertex2D],
  occluder_z: f32,
  camera: &Camera,
) -> Option<ShadowVolume> {
  if occluder_vertices_2d.len() < 2 {
    return None;
  }

  // Step 1: Lift 2D vertices to 3D
  let occluder_3d: Vec<Vec3> = occluder_vertices_2d
    .iter()
    .map(|vertex| Vec3::new(vertex.x, vertex.y, occluder_z))
    .collect();

  // Step 2: Shadow length based on distance from light
  let shadow_length = emitter.radius;

  // Step 3: Project screen-space light position for silhouette test
  let light_screen = camera.project(light_position);

  let mut screen_shadow_vertices: Vec<Vertex2D> = Vec::new();
  let vertex_count = occluder_3d.len();

  for edge_index in 0..vertex_count {
    let current_3d = occluder_3d[edge_index];
    let next_3d = occluder_3d[(edge_index + 1) % vertex_count];

    // Project edge to screen space for silhouette test
    let current_screen = camera.project(current_3d);
    let next_screen = camera.project(next_3d);

    // Silhouette test in screen space
    let edge_screen = next_screen - current_screen;
    let outward_normal = Vec2::new(edge_screen.y, -edge_screen.x);
    let light_to_edge = current_screen - light_screen;

    if outward_normal.dot(light_to_edge) <= 0.0 {
      continue;
    }

    // Step 4: Extrude in 3D, then project to screen
    let direction_current = (current_3d - light_position).normalize_or_zero();
    let direction_next = (next_3d - light_position).normalize_or_zero();
    let projected_current_3d = current_3d + direction_current * shadow_length;
    let projected_next_3d = next_3d + direction_next * shadow_length;

    // Project all four quad corners to screen space
    screen_shadow_vertices.push(current_screen);
    screen_shadow_vertices.push(next_screen);
    screen_shadow_vertices.push(camera.project(projected_next_3d));
    screen_shadow_vertices.push(camera.project(projected_current_3d));
  }

  if screen_shadow_vertices.is_empty() {
    return None;
  }

  // Attenuate by 3D distance from light to occluder center
  let occluder_center_3d = occluder_3d.iter().copied().sum::<Vec3>() / occluder_3d.len() as f32;
  let distance = light_position.distance(occluder_center_3d);
  let attenuation =
    emitter.intensity / (1.0 + distance * distance / (emitter.radius * emitter.radius));

  Some(ShadowVolume {
    screen_vertices: screen_shadow_vertices,
    color: emitter.color,
    intensity: attenuation,
  })
}

/// Check if a 3D world point falls within the light's cone
pub fn is_point_in_light_cone(
  transform: &TransformComponent,
  emitter: &LightEmitterComponent,
  world_point: Vec3,
) -> bool {
  let to_point = (world_point - transform.position).normalize_or_zero();
  let cos_angle = transform.direction.dot(to_point);
  cos_angle >= emitter.cone_angle.cos()
}

/// Compute light intensity at a 3D world point
pub fn compute_light_intensity(
  transform: &TransformComponent,
  emitter: &LightEmitterComponent,
  world_point: Vec3,
) -> f32 {
  if !is_point_in_light_cone(transform, emitter, world_point) {
    return 0.0;
  }

  // Inverse square falloff normalized by radius
  let distance_squared = transform.position.distance_squared(world_point);
  let radial_falloff = 1.0 / (1.0 + distance_squared / (emitter.radius * emitter.radius));

  // Smooth angular falloff near cone edge
  let to_point = (world_point - transform.position).normalize_or_zero();
  let cos_angle = transform.direction.dot(to_point);
  let cos_cone = emitter.cone_angle.cos();
  let angular_falloff = ((cos_angle - cos_cone) / (1.0 - cos_cone)).clamp(0.0, 1.0);

  emitter.intensity * radial_falloff * angular_falloff
}
