use super::component::VertexSlice;
use super::types::Vertex;

/// Per-frame vertex pool for 2D polygon data
///
/// Coordinate system: X right, Y up (world space)
#[derive(Debug, Default)]
pub struct VertexPool {
  vertices: Vec<Vertex>,
}

impl VertexPool {
  pub fn new() -> Self {
    Self {
      vertices: Vec::new(),
    }
  }

  pub fn clear(&mut self) {
    self.vertices.clear();
  }

  /// Push a polygon's vertices, returns a handle to the slice
  pub fn push_polygon(&mut self, vertices: &[Vertex]) -> VertexSlice {
    let start = self.vertices.len() as u32;
    self.vertices.extend_from_slice(vertices);
    VertexSlice {
      start,
      count: vertices.len() as u16,
    }
  }

  pub fn get_polygon(&self, slice: VertexSlice) -> &[Vertex] {
    let start = slice.start as usize;
    let end = start + slice.count as usize;
    &self.vertices[start..end]
  }

  pub fn vertices(&self) -> &[Vertex] {
    &self.vertices
  }

  pub fn vertex_count(&self) -> usize {
    self.vertices.len()
  }
}
