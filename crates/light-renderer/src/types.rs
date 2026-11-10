/// 2D vertex position in world space (X right, Y up)
pub type Vertex = glam::Vec2;

/// RGBA color with f32 channels in [0, 1]
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Color {
  pub r: f32,
  pub g: f32,
  pub b: f32,
  pub a: f32,
}

impl Color {
  pub const WHITE: Self = Self::new(1.0, 1.0, 1.0, 1.0);
  pub const BLACK: Self = Self::new(0.0, 0.0, 0.0, 1.0);
  pub const TRANSPARENT: Self = Self::new(0.0, 0.0, 0.0, 0.0);

  pub const fn new(r: f32, g: f32, b: f32, a: f32) -> Self {
    Self { r, g, b, a }
  }

  pub const fn rgb(r: f32, g: f32, b: f32) -> Self {
    Self::new(r, g, b, 1.0)
  }
}

impl Default for Color {
  fn default() -> Self {
    Self::WHITE
  }
}
