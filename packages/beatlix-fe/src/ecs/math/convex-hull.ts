import type {
  Vec2,
} from './vec2';

// Andrew's monotone chain algorithm for 2D convex hull
// Returns hull points in counter-clockwise order

export function computeConvexHull (points: Vec2[]): Vec2[] {
  const sorted = [...points].sort(
    (lhs, rhs) => lhs[0] - rhs[0] || lhs[1] - rhs[1],
  );

  if (sorted.length <= 2) {
    return sorted;
  }

  // Lower hull
  const lower: Vec2[] = [];

  for (const point of sorted) {
    while (2 <= lower.length && crossProduct(lower[lower.length - 2], lower[lower.length - 1], point) <= 0) {
      lower.pop();
    }
    lower.push(point);
  }

  // Upper hull
  const upper: Vec2[] = [];

  for (let index = sorted.length - 1; 0 <= index; index--) {
    const point = sorted[index];

    while (2 <= upper.length && crossProduct(upper[upper.length - 2], upper[upper.length - 1], point) <= 0) {
      upper.pop();
    }
    upper.push(point);
  }

  // Remove last point of each half (it's the first of the other)
  lower.pop();
  upper.pop();

  return [
    ...lower,
    ...upper,
  ];
}

function crossProduct (
  origin: Vec2,
  pointA: Vec2,
  pointB: Vec2,
): number {
  return (pointA[0] - origin[0]) * (pointB[1] - origin[1])
    - (pointA[1] - origin[1]) * (pointB[0] - origin[0]);
}
