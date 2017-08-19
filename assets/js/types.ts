declare module bs {
  export type Point = [number, number];

  export type Food = Point;

  export type Ctx = CanvasRenderingContext2D;

  export type Image = HTMLImageElement;

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
