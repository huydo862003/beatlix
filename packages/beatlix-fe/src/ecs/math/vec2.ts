export type Vec2 = [number, number];

export function addVec2 (lhs: Vec2, rhs: Vec2): Vec2 {
  return [
    lhs[0] + rhs[0],
    lhs[1] + rhs[1],
  ];
}

export function angleOfVec2 (vec: Vec2): number {
  return Math.atan2(vec[1], vec[0]);
}

export function createVec2 (px: number, py: number): Vec2 {
  return [
    px,
    py,
  ];
}

export function dotVec2 (lhs: Vec2, rhs: Vec2): number {
  return lhs[0] * rhs[0] + lhs[1] * rhs[1];
}

export function fromAngle (angle: number, magnitude: number = 1): Vec2 {
  return [
    Math.cos(angle) * magnitude,
    Math.sin(angle) * magnitude,
  ];
}

export function lengthVec2 (vec: Vec2): number {
  return Math.sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
}

export function normalizeVec2 (vec: Vec2): Vec2 {
  const length = lengthVec2(vec);

  if (length === 0) {
    return [
      0,
      0,
    ];
  }

  return [
    vec[0] / length,
    vec[1] / length,
  ];
}

export function rotateVec2 (vec: Vec2, angle: number): Vec2 {
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);

  return [
    vec[0] * cos - vec[1] * sin,
    vec[0] * sin + vec[1] * cos,
  ];
}

export function scaleVec2 (vec: Vec2, scalar: number): Vec2 {
  return [
    vec[0] * scalar,
    vec[1] * scalar,
  ];
}

export function subtractVec2 (lhs: Vec2, rhs: Vec2): Vec2 {
  return [
    lhs[0] - rhs[0],
    lhs[1] - rhs[1],
  ];
}
