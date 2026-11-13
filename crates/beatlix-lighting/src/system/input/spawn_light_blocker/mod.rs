mod convex_hull;
mod svg_loader;

use ecs::{EcsEntity, EcsWorld};
use glam::Vec3;

use crate::archetype::LightBlockerArchetype;
use crate::component::{LightOccluderComponent, LightReceiverComponent, TransformComponent};
use crate::types::Vertex2D;
use crate::world::LightWorld;

use convex_hull::compute_convex_hull;
use svg_loader::load_polygons_from_svg;

/// Spawn a light blocker entity from raw polygon vertices
pub fn spawn_light_blocker(
  world: &mut LightWorld,
  position: Vec3,
  vertices: &[Vertex2D],
) -> EcsEntity<LightBlockerArchetype> {
  let hull = compute_convex_hull(vertices);
  let occluder_slice = world.vertex_pool.push_polygon(&hull);
  let receiver_slice = world.vertex_pool.push_polygon(vertices);

  world.spawn(LightBlockerArchetype {
    transform: TransformComponent {
      position,
      direction: Vec3::Z,
    },
    occluder: LightOccluderComponent {
      vertices: occluder_slice,
    },
    receiver: LightReceiverComponent {
      vertices: receiver_slice,
    },
  })
}

/// Spawn light blocker entities from an SVG string
/// All vertices are offset by the XY components of the displacement vector
pub fn spawn_light_blockers_from_svg(
  world: &mut LightWorld,
  svg_data: &str,
  displacement: Vec3,
) -> Vec<EcsEntity<LightBlockerArchetype>> {
  let polygons = load_polygons_from_svg(svg_data, displacement.truncate());
  polygons
    .iter()
    .map(|polygon_vertices| spawn_light_blocker(world, displacement, polygon_vertices))
    .collect()
}
