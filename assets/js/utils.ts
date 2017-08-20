export function* entries<T>(list: bs.List<T>) {
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

export function embedApp<T>(tag: string, App: Elm.App<T>, config?: Elm.MetaData): Elm.Program<T>[] {
  const elements = entries(document.querySelectorAll(tag))

  return map(elements, (element) => {

    const attrs = entries(element.attributes);

    let options: Elm.MetaData = {};

    for (const a of attrs) {
      options[a.name] = a.value;
    }

    if (config) {
      Object.assign(options, config);
    }

    return (Object.keys(options).length < 1) ?
      App.embed(element) :
      App.embed(element, options);
  });
}
