declare module 'elm/Test' {
  interface Ports {
    render: Elm.Port<(world: bs.Board) => void>;
  }

  export const Test: Elm.App<Ports>;
}

declare module 'elm/Game' {
  interface Ports {
    render: Elm.Port<(world: bs.Board) => void>;
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

declare namespace bs {
  export type Point = [number, number];

  export type Food = Point;

  export type Ctx = CanvasRenderingContext2D & {
    filter: string;
    currentTransform: SVGMatrix;
  };

  export type Image = HTMLImageElement;

  export type List<T> = {length: number; item: (i: number) => T};

  export interface Snake {
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

  export interface Board {
    width: number;
    turn: number;
    snakes: Snake[];
    height: number;
    gameId: string;
    food: Food[];
    deadSnakes: any[];
  }

  export interface TickResponse {
    content: Board;
  }
}
