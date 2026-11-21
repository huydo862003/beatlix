//! WASM bindings for the lighting engine

use glam::Vec3;
use serde::{Deserialize, Serialize};
use tsify_next::Tsify;
use wasm_bindgen::prelude::*;

use crate::{
  Camera, Color, LightWorld, Vertex2D,
  system::{
    derived::compute_shadows,
    input::{spawn_light_blocker, spawn_light_emitter},
  },
};

// Input types: screen-space scene data from the TS layer

#[derive(Tsify, Deserialize)]
#[tsify(from_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct SceneInput {
  pub emitters: Vec<LightEmitter>,
  pub blockers: Vec<LightBlocker>,
  pub viewport: ViewportSize,
}

#[derive(Tsify, Deserialize)]
#[tsify(from_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct ViewportSize {
  pub width: f32,
  pub height: f32,
}

#[derive(Tsify, Deserialize)]
#[tsify(from_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct NormalizedRect {
  pub left: f32,
  pub top: f32,
  pub width: f32,
  pub height: f32,
}

#[derive(Tsify, Deserialize)]
#[tsify(from_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct LightEmitter {
  #[tsify(optional)]
  pub bounds: Option<NormalizedRect>,
  pub color: [f32; 4],
  pub intensity: f32,
  pub radius: f32,
  pub cone_angle: f32,
  pub direction: [f32; 3],
  pub depth: f32,
}

#[derive(Tsify, Deserialize)]
#[tsify(from_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct LightBlocker {
  pub bounds: NormalizedRect,
  pub depth: f32,
}

// Output types: shadow polygons in normalized screen space

#[derive(Tsify, Serialize)]
#[tsify(into_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct LightingResult {
  pub shadows: Vec<ShadowPolygon>,
}

#[derive(Tsify, Serialize)]
#[tsify(into_wasm_abi)]
#[serde(rename_all = "camelCase")]
pub struct ShadowPolygon {
  pub vertices: Vec<[f32; 2]>,
  pub color: [f32; 4],
  pub intensity: f32,
}

// Screen-to-world coordinate helpers
// Screen space: origin top-left, Y down, [0..1]
// World space: origin bottom-left, Y up, [0..1], Z = depth into room

fn bounds_to_world_center(bounds: Option<&NormalizedRect>, depth: f32) -> Vec3 {
  match bounds {
    Some(rect) => Vec3::new(
      rect.left + rect.width / 2.0,
      1.0 - (rect.top + rect.height / 2.0),
      depth,
    ),
    None => Vec3::new(0.5, 0.5, depth),
  }
}

fn bounds_to_world_rect(bounds: &NormalizedRect) -> [Vertex2D; 4] {
  let world_left = bounds.left;
  let world_right = bounds.left + bounds.width;
  let world_top = 1.0 - bounds.top;
  let world_bottom = 1.0 - (bounds.top + bounds.height);

  [
    Vertex2D::new(world_left, world_top),
    Vertex2D::new(world_right, world_top),
    Vertex2D::new(world_right, world_bottom),
    Vertex2D::new(world_left, world_bottom),
  ]
}

// Fixed orthographic camera: world [0,1] maps to NDC [-1,1]
fn room_camera(viewport: &ViewportSize) -> Camera {
  Camera::new_oblique(
    Vec3::new(0.5, 0.5, 10.0),
    Vec3::new(0.5, 0.5, 0.0),
    Vec3::Y,
    viewport.width,
    viewport.height,
  )
}

// Public WASM API

#[wasm_bindgen(js_name = "computeLighting")]
pub fn compute_lighting(scene: SceneInput) -> Result<LightingResult, JsValue> {
  let camera = room_camera(&scene.viewport);
  let mut world = LightWorld::new(camera);

  for emitter in &scene.emitters {
    let position = bounds_to_world_center(emitter.bounds.as_ref(), emitter.depth);

    spawn_light_emitter(
      &mut world,
      position,
      Vec3::from_array(emitter.direction),
      emitter.cone_angle,
      Color::new(
        emitter.color[0],
        emitter.color[1],
        emitter.color[2],
        emitter.color[3],
      ),
      emitter.intensity,
      emitter.radius,
    );
  }

  for blocker in &scene.blockers {
    let vertices = bounds_to_world_rect(&blocker.bounds);
    let position = Vec3::new(0.0, 0.0, blocker.depth);

    spawn_light_blocker(&mut world, position, &vertices);
  }

  let shadow_volumes = compute_shadows(&world);

  Ok(LightingResult {
    shadows: shadow_volumes
      .into_iter()
      .map(|volume| ShadowPolygon {
        vertices: volume
          .screen_vertices
          .iter()
          .map(|vertex| [(vertex.x + 1.0) * 0.5, 1.0 - (vertex.y + 1.0) * 0.5])
          .collect(),
        color: [
          volume.color.r,
          volume.color.g,
          volume.color.b,
          volume.color.a,
        ],
        intensity: volume.intensity,
      })
      .collect(),
  })
}
