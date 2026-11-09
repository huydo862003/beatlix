import {
  type Ref, onMounted, ref,
} from 'vue';
import type {
  Vec2,
} from '../math/vec2';
import {
  computeConvexHull,
} from '../math/convex-hull';

// Sample points along all SVG paths inside an element and compute the convex hull
// Returns normalized points (0-1) relative to the element's bounding box
export function useSvgSilhouette (elementRef: Ref<HTMLElement | undefined>) {
  const silhouette = ref<Vec2[]>([]);

  onMounted(() => {
    if (!elementRef.value) {
      return;
    }

    const svgElement = elementRef.value.querySelector('svg');

    if (!svgElement) {
      return;
    }

    const points = extractSvgPoints(svgElement);

    if (points.length < 3) {
      return;
    }

    silhouette.value = computeConvexHull(points);
  });

  return silhouette;
}

function extractSvgPoints (svg: SVGSVGElement): Vec2[] {
  const viewBox = svg.viewBox.baseVal;
  const viewWidth = viewBox.width || svg.clientWidth;
  const viewHeight = viewBox.height || svg.clientHeight;

  if (viewWidth === 0 || viewHeight === 0) {
    return [];
  }

  const points: Vec2[] = [];
  const paths = svg.querySelectorAll('path, circle, ellipse, rect, polygon, line');

  for (const element of paths) {
    sampleElementPoints(element, viewWidth, viewHeight, points);
  }

  return points;
}

function sampleElementPoints (
  element: Element,
  viewWidth: number,
  viewHeight: number,
  points: Vec2[],
) {
  if (element instanceof SVGGeometryElement) {
    const totalLength = element.getTotalLength();
    // Sample every ~10 units of path length, minimum 8 samples
    const sampleCount = Math.max(8, Math.ceil(totalLength / 10));

    for (let index = 0; index <= sampleCount; index++) {
      const point = element.getPointAtLength((index / sampleCount) * totalLength);

      points.push([
        point.x / viewWidth,
        point.y / viewHeight,
      ]);
    }
  }
}
