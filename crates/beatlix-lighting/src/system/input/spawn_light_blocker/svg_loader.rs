use glam::Vec2;

use crate::types::Vertex2D;

/// Extract polygon outlines from an SVG string
/// All vertices are offset by the displacement vector
pub(super) fn load_polygons_from_svg(svg_data: &str, displacement: Vertex2D) -> Vec<Vec<Vertex2D>> {
  // Step 1: Parse SVG string into a simplified tree
  let options = usvg::Options::default();
  let tree = usvg::Tree::from_str(svg_data, &options).expect("failed to parse SVG");

  // Step 2: Recursively collect all closed paths as vertex lists
  let mut polygons = Vec::new();
  collect_paths(tree.root(), &mut polygons);

  // Step 3: Apply displacement to all vertices
  if displacement != Vertex2D::ZERO {
    for polygon in &mut polygons {
      for vertex in polygon {
        *vertex += displacement;
      }
    }
  }

  polygons
}

fn collect_paths(group: &usvg::Group, polygons: &mut Vec<Vec<Vertex2D>>) {
  for child in group.children() {
    match child {
      // Recurse into nested groups
      usvg::Node::Group(subgroup) => {
        collect_paths(subgroup, polygons);
      }
      // Convert path segments to vertices, discard degenerate paths
      usvg::Node::Path(path) => {
        let vertices = path_to_vertices(path);
        if vertices.len() >= 3 {
          polygons.push(vertices);
        }
      }
      _ => {}
    }
  }
}

/// Convert SVG path segments to line vertices
fn path_to_vertices(path: &usvg::Path) -> Vec<Vertex2D> {
  let mut vertices = Vec::new();

  for segment in path.data().segments() {
    match segment {
      // Start a new sub-path
      usvg::tiny_skia_path::PathSegment::MoveTo(point) => {
        vertices.push(Vec2::new(point.x, point.y));
      }
      // Straight line to next point
      usvg::tiny_skia_path::PathSegment::LineTo(point) => {
        vertices.push(Vec2::new(point.x, point.y));
      }
      // Flatten quadratic Bezier to line segments
      usvg::tiny_skia_path::PathSegment::QuadTo(control, end) => {
        flatten_quad_bezier(
          *vertices.last().unwrap_or(&Vec2::ZERO),
          Vec2::new(control.x, control.y),
          Vec2::new(end.x, end.y),
          &mut vertices,
        );
      }
      // Flatten cubic Bezier to line segments
      usvg::tiny_skia_path::PathSegment::CubicTo(control1, control2, end) => {
        flatten_cubic_bezier(
          *vertices.last().unwrap_or(&Vec2::ZERO),
          Vec2::new(control1.x, control1.y),
          Vec2::new(control2.x, control2.y),
          Vec2::new(end.x, end.y),
          &mut vertices,
        );
      }
      usvg::tiny_skia_path::PathSegment::Close => {}
    }
  }

  vertices
}

/// Approximate a quadratic Bezier as 8 line segments
/// P(t) = (1-t)^2*start + 2(1-t)t*control + t^2*end
fn flatten_quad_bezier(
  start: Vertex2D,
  control: Vertex2D,
  end: Vertex2D,
  output: &mut Vec<Vertex2D>,
) {
  let steps = 8;
  for step in 1..=steps {
    // Evaluate the curve at evenly spaced t values
    let progress = step as f32 / steps as f32;
    let inverse = 1.0 - progress;
    let point =
      start * inverse * inverse + control * 2.0 * inverse * progress + end * progress * progress;
    output.push(point);
  }
}

/// Approximate a cubic Bezier as 12 line segments
/// P(t) = (1-t)^3*start + 3(1-t)^2*t*c1 + 3(1-t)*t^2*c2 + t^3*end
fn flatten_cubic_bezier(
  start: Vertex2D,
  control1: Vertex2D,
  control2: Vertex2D,
  end: Vertex2D,
  output: &mut Vec<Vertex2D>,
) {
  let steps = 12;
  for step in 1..=steps {
    // Evaluate the curve at evenly spaced t values
    let progress = step as f32 / steps as f32;
    let inverse = 1.0 - progress;
    let point = start * inverse * inverse * inverse
      + control1 * 3.0 * inverse * inverse * progress
      + control2 * 3.0 * inverse * progress * progress
      + end * progress * progress * progress;
    output.push(point);
  }
}
