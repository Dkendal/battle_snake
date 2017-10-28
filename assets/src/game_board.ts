import {loadImage} from './images';
import {add, sub, uniq} from './point';
import * as P from './point';

const gutter = 0.1;
const unit = 1 - gutter * 2;
const halfUnit = unit / 2;
const offset = unit / 2 * -1;
const coordCache: WeakMap<bs.Snake, Array<bs.Point>> = new WeakMap();

function coords(snake: bs.Snake): bs.Point[] {
  const coords = coordCache.get(snake);

  if (coords) {
    return coords;
  }

  const arr = uniq(snake.coords);

  coordCache.set(snake, arr);

  return arr;
}

function clear(ctx: bs.Ctx) {
  const {width, height} = ctx.canvas;
  ctx.clearRect(0, 0, width, height);
}

function drawFood(layer: bs.Ctx, [x, y]: bs.Food) {
  layer.beginPath();
  layer.arc(x, y, halfUnit, 0, 2 * Math.PI);
  layer.fill();
}

function drawGrid(layer: bs.Ctx, width: number, height: number) {
  for (let i = 0; i < width; i++) {
    for (let j = 0; j < height; j++) {
      layer.fillRect(i + gutter, j + gutter, unit, unit);
    }
  }
}

/**
 * Save the transform, apply a function, and restore the transform.
 */
function within(ctx: bs.Ctx, fn: Function): void {
  ctx.save();
  fn();
  ctx.restore();
}

function drawSnakeBody(layer: bs.Ctx, snake: bs.Snake, prepare?: Function) {
  const points = P.shrink(P.smooth(snake.coords), 0.12);

  within(layer, () => {
    layer.translate(0.5, 0.5);

    layer.strokeStyle = snake.color;

    layer.lineWidth = unit;

    layer.lineJoin = 'round';

    prepare && prepare();

    layer.beginPath();

    layer.moveTo(points[0][0], points[0][1]);

    for (let i = 1; i < points.length; i += 1) {
      const x0 = points[i];
      layer.lineTo(x0[0], x0[1]);
    }

    layer.stroke();
  });
}

function headImgId(snake: bs.Snake): string {
  return `snake-head-${snake.headType}`;
}

function tailImgId(snake: bs.Snake): string {
  return `snake-tail-${snake.tailType}`;
}

function drawImage(
  layer: bs.Ctx,
  image: bs.Image,
  h0: bs.Point,
  h1: bs.Point,
  prepare?: Function
) {
  const v = sub(h0, h1);

  let a = add([0.5, 0.5], h0);

  within(layer, () => {
    layer.translate(a[0], a[1]);

    switch (v.join(' ')) {
      case '0 -1':
        layer.rotate(-Math.PI / 2);
        break;

      case '0 1':
        layer.rotate(Math.PI / 2);
        break;

      case '-1 0':
        layer.scale(-1, 1);
        break;
    }

    prepare && prepare();

    layer.drawImage(image, offset, offset, unit, unit);
  });
}

async function drawSnake(
  layer: bs.Ctx,
  head: Promise<bs.Image>,
  tail: Promise<bs.Image>,
  snake: bs.Snake,
  prepare?: Function
): Promise<null> {
  const coordinates = coords(snake);

  const [h0, h1] = coordinates;
  const [t1, t0] = coordinates.slice(-2);

  const headImg = await head;
  const tailImg = await tail;

  drawSnakeBody(layer, snake, prepare);

  drawImage(layer, headImg, h0, h1 || h0, prepare);

  if (coordinates.length > 1) {
    drawImage(layer, tailImg, t0 || t1, t1, prepare);
  }

  return null;
}

export class GameBoard {
  private readonly ctx: bs.Ctx;
  private readonly images = new Map();
  private readonly colorPallet: Map<string, string>;

  constructor(ctx: bs.Ctx, colorPallet: Map<string, string>) {
    this.ctx = ctx;
    this.colorPallet = colorPallet;
  }

  color(name: string): string {
    return this.colorPallet.get(name) || 'pink';
  }

  async getImage(id: string, color: string): Promise<bs.Image> {
    const key = `${id}-${color}`;

    const image = this.images.get(key);

    if (image) {
      return image;
    }

    const img = await loadImage(id, color);

    this.images.set(key, img);

    return img;
  }

  async draw(world: bs.Board) {
    const ctx = this.ctx;

    // Adjust coordinate system if the window has been resized
    // since the last draw.
    const clientWidth = this.ctx.canvas.width;
    const clientHeight = this.ctx.canvas.height;
    const {width, height} = world;

    const h = clientHeight / height;
    const w = clientWidth / width;
    const sign = clientWidth / clientHeight > width / height;
    const scaler = sign ? h : w;

    const xT = sign ? (clientWidth - h * width) / 2 : 0;
    const yT = sign ? 0 : (clientHeight - w * height) / 2;

    // Scale the world and set the coordinate system so that 1
    // unit corresponds to a single tile and the world is
    // centered.
    clear(ctx);
    ctx.translate(xT, yT);
    ctx.scale(scaler, scaler);

    // Draw the grid
    ctx.fillStyle = this.color('tile-color');
    drawGrid(ctx, width, height);

    // Draw food
    within(ctx, () => {
      ctx.fillStyle = this.color('food-color');
      ctx.translate(0.5, 0.5);

      for (const food of world.food) {
        drawFood(ctx, food);
      }
    });

    for (const snake of world.deadSnakes) {
      const x =  snake.death.turn - world.turn
      const a = 1.1 ** x

      if (a < 0.05) {
        continue;
      }

      const head = this.getImage(headImgId(snake), snake.color);
      const tail = this.getImage(tailImgId(snake), snake.color);

      drawSnake(ctx, head, tail, snake, () => {
        ctx.filter = `grayscale(${20 + Math.abs(x * 10)}%)`;
        ctx.globalAlpha = a;
      });
    }

    for (const snake of world.snakes) {
      const head = this.getImage(headImgId(snake), snake.color);
      const tail = this.getImage(tailImgId(snake), snake.color);

      drawSnake(ctx, head, tail, snake);
    }
  }
}
