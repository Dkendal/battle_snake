/**
 * Pipe Monad
 */
class Pipe<T> {
  private readonly val: T;

  constructor(val: T) {
    this.val = val;
  }

  get value(): T {
    return this.val;
  }

  map<S>(f: ((t: T) => S)): Pipe<S> {
    return new Pipe(f(this.value))
  }
}

export function pipe<T>(val: T) {
  return new Pipe(val);
}
