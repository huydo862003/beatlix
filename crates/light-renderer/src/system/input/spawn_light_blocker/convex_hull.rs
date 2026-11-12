use crate::types::Vertex2D;

/// Compute the convex hull of a set of 2D points using Graham scan
/// Returns vertices in counter-clockwise order
///
/// Reference: https://en.wikipedia.org/wiki/Graham_scan
/// TIL: Interesting algo, worth contemplating
pub(super) fn compute_convex_hull(points: &[Vertex2D]) -> Vec<Vertex2D> {
  if points.len() < 3 {
    return points.to_vec();
  }

  let mut sorted: Vec<Vertex2D> = points.to_vec();

  // Step 1: Find the bottom-most point as the pivot
  // (lowest y, then leftmost x to break ties)
  let pivot_index = sorted
    .iter()
    .enumerate()
    .min_by(|(_, first), (_, second)| {
      first
        .y
        .total_cmp(&second.y)
        .then(first.x.total_cmp(&second.x))
    })
    .map(|(index, _)| index)
    .unwrap();

  sorted.swap(0, pivot_index);
  let pivot = sorted[0];

  // Step 2: Sort remaining points by polar angle relative to the pivot
  // (closer points first when angles are equal)
  sorted[1..].sort_by(|first, second| {
    let angle_first = (*first - pivot).to_angle();
    let angle_second = (*second - pivot).to_angle();
    angle_first.total_cmp(&angle_second).then_with(|| {
      pivot
        .distance_squared(*first)
        .total_cmp(&pivot.distance_squared(*second))
    })
  });

  // Step 3: Walk through sorted points, maintaining a stack
  // Pop the top if the last three points make a clockwise turn
  // (perp_dot <= 0 means clockwise or collinear)
  let mut hull: Vec<Vertex2D> = Vec::with_capacity(points.len());
  for point in &sorted {
    while hull.len() >= 2
      && (hull[hull.len() - 1] - hull[hull.len() - 2]).perp_dot(*point - hull[hull.len() - 2])
        <= 0.0
    {
      hull.pop();
    }
    hull.push(*point);
  }

  hull
}
