use ecs::EcsWorld;

use crate::archetype::{LightBlockerArchetype, LightEmitterArchetype};
use crate::component::{LightEmitterComponent, LightOccluderComponent};
use crate::types::{Color, Vertex2D};
use crate::world::LightWorld;

/// A shadow cast by a light hitting an occluder
#[derive(Debug)]
pub struct ShadowVolume {
  pub vertices: Vec<Vertex2D>,
  pub color: Color,
  pub intensity: f32,
}

/// Compute shadow volumes from light emitters and occluders
pub fn compute_shadows(world: &LightWorld) -> Vec<ShadowVolume> {
  let mut shadows = Vec::new();

  let Some(emitters) = world.component_slice::<LightEmitterArchetype, LightEmitterComponent>()
  else {
    return shadows;
  };

  let Some(occluders) = world.component_slice::<LightBlockerArchetype, LightOccluderComponent>()
  else {
    return shadows;
  };

  for emitter in emitters {
    for occluder in occluders {
      let occluder_vertices = world.vertex_pool.get_polygon(occluder.vertices);
      let shadow = project_shadow(emitter, occluder_vertices);
      shadows.push(shadow);
    }
  }

  shadows
}

/// Project occluder edges away from a light source to form a shadow polygon
fn project_shadow(emitter: &LightEmitterComponent, occluder_vertices: &[Vertex2D]) -> ShadowVolume {
  // TODO: implement proper 2D shadow projection
  ShadowVolume {
    vertices: occluder_vertices.to_vec(),
    color: emitter.color,
    intensity: emitter.intensity,
  }
}
