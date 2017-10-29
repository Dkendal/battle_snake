export function* entries<T>(list: List<T>) {
  for (let i = 0; i < list.length; i++) {
    yield list.item(i);
  }
}

export function map<T, K>(iter: IterableIterator<T>, mapper: (x: T) => K): K[] {
  return Array.from(iter, mapper);
}

export function array<T>(iter: IterableIterator<T>): T[] {
  return map(iter, x => x);
}
