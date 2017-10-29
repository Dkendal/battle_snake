declare module 'elm/Test' {
  interface Ports {
    render: Elm.Port<(world: Board) => void>;
  }

  export const Test: Elm.App<Ports>;
}

declare module 'elm/Game' {
  interface Ports {
    render: Elm.Port<(world: Board) => void>;
  }

  export const Game: Elm.App<Ports>;
}

declare namespace Elm {
  export interface Port<T> {
    subscribe(callback: T): void;
  }

  export interface Program<T> {
    ports: T;
  }

  export interface App<T> {
    fullscreen(): Program<T>;
    embed(node: Element, options?: MetaData): Program<T>;
  }

  export interface MetaData {
    [key: string]: any;
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
  causeOfDeath: string;
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
