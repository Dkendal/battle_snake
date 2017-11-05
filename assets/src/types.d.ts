declare module 'elm/Test' {
  interface Ports {
    render: Elm.Port<(world: Board) => void>;
  }

  export const Test: Elm.App<Ports, {websocket: string}>;
}

declare module 'elm/Game' {
  interface Ports {
    render: Elm.Port<(world: Board) => void>;
  }

  export const Game: Elm.App<Ports, {websocket: string}>;
}

declare namespace Elm {
  export interface Port<T> {
    subscribe(callback: T): void;
  }

  export interface Program<T> {
    ports: T;
  }

  export interface App<T, Options> {
    fullscreen(options?: Options): Program<T>;
    embed(node: Element, options?: Options): Program<T>;
  }
}

type Point = [number, number];

type Food = Point;

type Ctx = CanvasRenderingContext2D & {
  filter: string;
  currentTransform: SVGMatrix;
};

type Image = HTMLImageElement;

type List<T> = {length: number; item: (i: number) => T};

interface Snake {
  taunt?: any;
  name: string;
  id: string;
  healthPoints: number;
  headType: string;
  tailType: string;
  coords: Point[];
  color: string;
  death: string;
}

interface Board {
  width: number;
  turn: number;
  snakes: Snake[];
  height: number;
  gameId: string;
  food: Food[];
  deadSnakes: any[];
}

interface TickResponse {
  content: Board;
}
