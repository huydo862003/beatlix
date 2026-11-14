//! WASM bindings for the lighting engine

use glam::Vec3;
use serde::{Deserialize, Serialize};
use wasm_bindgen::prelude::*;

use crate::{
  Camera, Color, LightWorld, Vertex2D,
  system::{
    derived::compute_shadows,
    input::{spawn_light_blocker, spawn_light_emitter},
  },
};

// Input: screen-space scene data from the TS composable layer

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct SceneInput {
  emitters: Vec<ScreenEmitter>,
  blockers: Vec<ScreenBlocker>,
  viewport: Viewport,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct Viewport {
  width: f32,
  height: f32,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ScreenBounds {
  left: f32,
  top: f32,
  width: f32,
  height: f32,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ScreenEmitter {
  bounds: Option<ScreenBounds>,
  color: [f32; 4],
  intensity: f32,
  radius: f32,
  cone_angle: f32,
  direction: [f32; 3],
  depth: f32,
}

#[derive(Deserialize)]
#[serde(rename_all = "camelCase")]
struct ScreenBlocker {
  bounds: ScreenBounds,
  depth: f32,
}

// Output: shadow polygons in normalized screen space

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct LightingOutput {
  shadows: Vec<ShadowPolygon>,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct ShadowPolygon {
  vertices: Vec<[f32; 2]>,
  color: [f32; 4],
  intensity: f32,
}

// Screen-to-world coordinate helpers
// Screen space: origin top-left, Y down, [0..1]
// World space: origin bottom-left, Y up, [0..1], Z = depth into room

fn screen_bounds_to_world_center(bounds: Option<&ScreenBounds>, depth: f32) -> Vec3 {
  match bounds {
    Some(rect) => Vec3::new(
      rect.left + rect.width / 2.0,
      1.0 - (rect.top + rect.height / 2.0),
      depth,
    ),
    None => Vec3::new(0.5, 0.5, depth),
  }
}

fn screen_bounds_to_world_rect(bounds: &ScreenBounds) -> [Vertex2D; 4] {
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
fn room_camera(viewport: &Viewport) -> Camera {
  Camera::new_oblique(
    Vec3::new(0.5, 0.5, 10.0),
    Vec3::new(0.5, 0.5, 0.0),
    Vec3::Y,
    viewport.width,
    viewport.height,
  )
}

// Public API

#[wasm_bindgen]
pub fn compute_lighting(scene: JsValue) -> Result<JsValue, JsValue> {
  let scene: SceneInput =
    serde_wasm_bindgen::from_value(scene).map_err(|error| JsValue::from_str(&error.to_string()))?;

  let camera = room_camera(&scene.viewport);
  let mut world = LightWorld::new(camera);

  for emitter in &scene.emitters {
    let position = screen_bounds_to_world_center(emitter.bounds.as_ref(), emitter.depth);

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
    let vertices = screen_bounds_to_world_rect(&blocker.bounds);
    let position = Vec3::new(0.0, 0.0, blocker.depth);

    spawn_light_blocker(&mut world, position, &vertices);
  }

  let shadow_volumes = compute_shadows(&world);

  let output = LightingOutput {
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
  };

  serde_wasm_bindgen::to_value(&output).map_err(|error| JsValue::from_str(&error.to_string()))
}
