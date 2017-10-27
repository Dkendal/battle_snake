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

function drawSnakeBody(layer: bs.Ctx, snake: bs.Snake) {
  const points = P.shrink(P.smooth(snake.coords), 0.12);

  layer.save();

  layer.strokeStyle = snake.color;

  layer.lineWidth = unit;

  layer.lineJoin = 'round';

  layer.translate(0.5, 0.5);

  layer.beginPath();

  layer.moveTo(points[0][0], points[0][1]);

  for (let i = 1; i < points.length; i += 1) {
    const x0 = points[i];
    layer.lineTo(x0[0], x0[1]);
  }

  layer.stroke();

  layer.restore();
}

function drawImage(layer: bs.Ctx, image: bs.Image, h0: bs.Point, h1: bs.Point) {
  const v = sub(h0, h1);

  let a = add([0.5, 0.5], h0);

  layer.save();

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

  layer.drawImage(image, offset, offset, unit, unit);

  layer.restore();
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

  headImage(snake: bs.Snake): Promise<bs.Image> {
    const id = `snake-head-${snake.headType}`;
    return this.getImage(id, snake.color);
  }

  tailImage(snake: bs.Snake): Promise<bs.Image> {
    const id = `snake-tail-${snake.tailType}`;
    return this.getImage(id, snake.color);
  }

  async drawImages(layer: bs.Ctx, board: bs.Board): Promise<{}> {
    for (const snake of board.snakes) {
      drawSnakeBody(layer, snake);
    }

    const tasks = board.snakes.map(async snake => {
      const head = this.headImage(snake);
      const tail = this.tailImage(snake);

      const coordinates = coords(snake);

      const [h0, h1] = coordinates;
      const [t1, t0] = coordinates.slice(-2);

      const headImg = await head;
      const tailImg = await tail;

      drawImage(layer, headImg, h0, h1 || h0);

      if (coordinates.length > 1) {
        drawImage(layer, tailImg, t0 || t1, t1);
      }
    });

    return Promise.all(tasks);
  }
  async draw(board: bs.Board) {
    const ctx = this.ctx;

    // Adjust coordinate system if the window has been resized
    // since the last draw.
    const clientWidth = this.ctx.canvas.width;
    const clientHeight = this.ctx.canvas.height;
    const {width, height} = board;

    const h = clientHeight / height;
    const w = clientWidth / width;
    const sign = clientWidth / clientHeight > width / height;
    const scaler = sign ? h : w;

    const xT = sign ? (clientWidth - h * width) / 2 : 0;
    const yT = sign ? 0 : (clientHeight - w * height) / 2;

    // Scale the board and set the coordinate system so that 1
    // unit corresponds to a single tile and the board is
    // centered.
    clear(ctx);
    ctx.translate(xT, yT);
    ctx.scale(scaler, scaler);

    // Draw the grid
    ctx.fillStyle = this.color('tile-color');
    drawGrid(ctx, width, height);

    // Draw food
    ctx.save();
    ctx.translate(0.5, 0.5);
    ctx.fillStyle = this.color('food-color');

    for (const food of board.food) {
      drawFood(ctx, food);
    }
    ctx.restore();

    // Draw snakes
    await this.drawImages(ctx, board);
  }
}
