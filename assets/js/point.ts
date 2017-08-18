export function add([x0, x1]: bs.Point, [y0, y1]: bs.Point): bs.Point {
  return [x0 + y0, x1 + y1];
}

export function mul([x0, x1]: bs.Point, s: number): bs.Point {
  return [x0 * s, x1 * s];
}

export function div(a: bs.Point, s: number): bs.Point {
  return mul(a, 1 / s);
}

export function sub(a: bs.Point, b: bs.Point): bs.Point {
  return add(a, mul(b, -1));
}

export function eq(a: bs.Point, b: bs.Point): boolean {
  return a[0] === b[0] && a[1] === b[1];
}

export function uniq(s: bs.Point[]): bs.Point[] {
  return s.reduce(([y, ...s], x) => {
    if (!eq(y, x)) {
      return [x, y, ...s];
    }
    return [y, ...s];
  }, [s[0]])
    .reverse();
}

// Add an interpolated point between every point in points.
export function smooth(points: bs.Point[]) {
  return points.reduce(
    ([b, ...s], a) => {
      const mean = div(add(a, b), 2);
      return [a, mean, b, ...s];
    },
    [points[0]]);
}
