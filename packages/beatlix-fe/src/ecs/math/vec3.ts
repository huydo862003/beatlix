export type Vec3 = [number, number, number];

export function addVec3 (lhs: Vec3, rhs: Vec3): Vec3 {
  return [
    lhs[0] + rhs[0],
    lhs[1] + rhs[1],
    lhs[2] + rhs[2],
  ];
}

export function createVec3 (px: number, py: number, pz: number): Vec3 {
  return [
    px,
    py,
    pz,
  ];
}

export function lengthVec3 (vec: Vec3): number {
  return Math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
}

export function normalizeVec3 (vec: Vec3): Vec3 {
  const length = lengthVec3(vec);

  if (length === 0) {
    return [
      0,
      0,
      0,
    ];
  }

  return [
    vec[0] / length,
    vec[1] / length,
    vec[2] / length,
  ];
}

export function scaleVec3 (vec: Vec3, scalar: number): Vec3 {
  return [
    vec[0] * scalar,
    vec[1] * scalar,
    vec[2] * scalar,
  ];
}
