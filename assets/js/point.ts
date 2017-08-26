export function add(a: bs.Point, b: bs.Point): bs.Point {
  return map2(a, b, (x, y) => x + y);
}

export function mul(a: bs.Point, s: number): bs.Point {
  return map(a, x => x * s);
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

export function round(a: bs.Point): bs.Point {
  return map(a, Math.round);
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

export function map<T>(a: bs.Point, fn: (x: number) => T): [T, T] {
  return [fn(a[0]), fn(a[1])];
}

export function map2<T>(a: bs.Point, b: bs.Point, fn: (x: number, y: number) => T): [T, T] {
  return [fn(a[0], b[0]), fn(a[1], b[1])];
}
