import {Pipe} from './monad';

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
  return s
    .reduce(
      ([y, ...s], x) => {
        if (!eq(y, x)) {
          return [x, y, ...s];
        }
        return [y, ...s];
      },
      [s[0]]
    )
    .reverse();
}

// Add an interpolated point between every point in points.
export function smooth(points: bs.Point[]): bs.Point[] {
  return points.reduce((s: bs.Point[], a: bs.Point) => {
    if (s.length === 0) {
      return [a];
    }

    const [h, ...t] = s;
    const mean = div(add(a, h), 2);
    return [a, mean, h, ...t];
  }, []);
}

// Move the first and last points closer together.
export function shrink(points: bs.Point[], scaler: number): bs.Point[] {
  const [p0, p1] = points.slice(0, 2);
  const [s1, s0] = points.slice(-2);

  const pPrime = new Pipe(p0)
    .bind(p => sub(p, p1))
    .bind(normalize)
    .bind(p => mul(p, scaler))
    .bind(p => add(p, p1)).value;

  const sPrime = new Pipe(s0)
    .bind(p => sub(p, s1))
    .bind(normalize)
    .bind(p => mul(p, scaler))
    .bind(p => add(p, s1)).value;

  return [pPrime, p1, ...points.slice(1, -1), s1, sPrime];
}

export function map<T>(a: bs.Point, fn: (x: number) => T): [T, T] {
  return [fn(a[0]), fn(a[1])];
}

export function map2<T>(
  a: bs.Point,
  b: bs.Point,
  fn: (x: number, y: number) => T
): [T, T] {
  return [fn(a[0], b[0]), fn(a[1], b[1])];
}

/**
 * Magnitude
 */
function mag([x, y]: bs.Point): number {
  return Math.sqrt(x * x + y * y);
}

function normalize(a: bs.Point): bs.Point {
  const m = mag(a);
  return map(a, x => (m ? x / m : 0));
}
