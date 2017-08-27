/**
 * Pipe Monad
 */
export class Pipe<T> {
  private readonly val: T;

  constructor(val: T) {
    this.val = val;
  }

  get value(): T {
    return this.val;
  }

  bind<S>(f: ((t: T) => S)): Pipe<S> {
    return new Pipe(f(this.value))
  }
}
