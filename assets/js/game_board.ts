import { add, div, sub, uniq, smooth } from 'point';

function noop() { }

const gutter = 0.1;
const unit = 1 - gutter * 2;
const halfUnit = unit / 2;
const offset = unit / 2 * -1;
const coordCache: WeakMap<bs.Snake, Array<bs.Point>> = new WeakMap();

function coords(snake: bs.Snake): bs.Point[] {
  const coords = coordCache.get(snake)

  if (coords) {
    return coords;
  }

  const arr = uniq(snake.coords);

  coordCache.set(snake, arr);

  return arr;
}

function get(href: string): Promise<SVGSVGElement> {
  return new Promise((resolve, reject) => {
    const request = new XMLHttpRequest();

    request.open("GET", href);

    request.addEventListener("load", (event: ProgressEvent) => {
      const request = <XMLHttpRequest>event.currentTarget;

      const xml = request.responseXML;

      if (!xml || !xml.children[0]) {
        return reject('no xml data');
      }

      return resolve(<SVGSVGElement>xml.children[0]);
    });

    request.send();
  });
}

function svg2image(svg: SVGSVGElement, color: string) {
  svg.setAttribute('fill', color)

  const DOMURL = window.URL || window;

  const image = new Image();

  const blob = new Blob([svg.outerHTML], { type: 'image/svg+xml' });

  const url = DOMURL.createObjectURL(blob);

  image.src = url

  return image
}

function loadImage(id: string, color: string): Promise<bs.Image> {
  const link = <HTMLLinkElement | null>document.getElementById(id);

  if (!link || !link.href) {
    return Promise.reject('no href on link');
  }

  return get(link.href).then((svg: SVGSVGElement) => {
    return svg2image(svg, color);
  });
}

export class GameBoard {
  private readonly bgctx: bs.Ctx;
  private readonly fgctx: bs.Ctx;
  private readonly images = new Map();
  private readonly colorPallet: Map<string, string>;
  private lastDim : {width: number, height: number} = {width: -1, height: -1};

  constructor(
    fgctx: bs.Ctx,
    bgctx: bs.Ctx,
    colorPallet: Map<string, string>
  ) {
    this.bgctx = bgctx;
    this.fgctx = fgctx;
    this.colorPallet = colorPallet;
  }

  color(name: string): string {
    return this.colorPallet.get(name) || 'pink';
  }

  drawGrid(width: number, height: number) {
    this.clear(this.bgctx, width, height);

    this.bgctx.fillStyle = this.color('background');

    for (let i = 0; i < width; i++) {
      for (let j = 0; j < height; j++) {
        this.bgctx.fillRect(i + gutter, j + gutter, unit, unit);
      }
    }
  }

  getImage(id: string, color: string): bs.Image {
    const key = `${id}-${color}`

    const image = this.images.get(key);

    if (image) {
      return image;
    }

    loadImage(id, color).then((image: bs.Image) => {
      this.images.set(key, image);
    });

    return new Image();
  }

  headImage(snake: bs.Snake): bs.Image {
    const id = `snake-head-${snake.headType}`;
    return this.getImage(id, snake.color);
  }

  tailImage(snake: bs.Snake): bs.Image {
    const id = `snake-tail-${snake.tailType}`;
    return this.getImage(id, snake.color);
  }

  drawSnakeBody(snake: bs.Snake) {
    const coordinates = smooth(coords(snake)).slice(1, -2);

    if (coordinates.length < 4) {
      return;
    }

    const [head, ...rest] = coordinates;

    const ctx = this.fgctx;

    ctx.save();

    ctx.translate(0.5, 0.5);

    ctx.beginPath();

    ctx.strokeStyle = snake.color;

    ctx.lineWidth = unit;

    ctx.moveTo(head[0], head[1]);

    for (let i = 0; i < (rest.length - 1); i += 2) {
      const c = rest[i];
      const x = rest[i + 1];
      ctx.quadraticCurveTo(c[0], c[1], x[0], x[1]);
    }

    ctx.stroke();

    ctx.restore();
  }

  drawImages(snake: bs.Snake) {
    const coordinates = coords(snake);

    const [h0, h1] = coordinates;
    const [t1, t0] = coordinates.slice(-2);

    const head = this.headImage(snake);
    const tail = this.tailImage(snake);

    // h1 or t0 may be nil.
    this.drawImage(head, h0, h1 || h0);
    this.drawImage(tail, t0 || t1, t1);
  }

  drawImage(image: bs.Image, h0: bs.Point, h1: bs.Point) {
    const ctx = this.fgctx;

    const v = sub(h0, h1);

    const a =
      add([0.5, 0.5], // translate to centre of point
        sub(h0, // move to coordinate
          div(v, 10))); // move to border of path

    ctx.save();

    ctx.translate(a[0], a[1]);

    switch (v.join(' ')) {
      case '0 -1':
        ctx.rotate(-Math.PI / 2);
        break;

      case '0 1':
        ctx.rotate(Math.PI / 2);
        break;

      case '-1 0':
        ctx.scale(-1, 1);
        break;
    }

    ctx.drawImage(image, offset, offset, unit, unit);

    ctx.restore();
  }

  drawFood([x, y]: bs.Food) {
    const ctx = this.fgctx;
    ctx.fillStyle = this.color('food');
    ctx.beginPath();
    ctx.arc(x, y, halfUnit, 0, 2 * Math.PI);
    ctx.fill();
  }

  clear(ctx: bs.Ctx) {
    const {width, height} = ctx.canvas;
    ctx.clearRect(0, 0, width, height);
  }

  hasDimChanged({width, height}: bs.Board) {
    return {width, height} != this.lastDim;
  }

  draw(board: bs.Board) {
    const ctxs = [this.bgctx, this.fgctx];

    const clientWidth = this.bgctx.canvas.width;
    const clientHeight = this.bgctx.canvas.height;
    const {width, height} = board;

    const h = clientHeight / height;
    const w = clientWidth / width;
    const sign = (clientWidth / clientHeight) > ( width / height )
    const scaler = sign ? h : w

    const xT = sign ? (clientWidth - h * width) / 2 : 0;
    const yT = sign ? 0 : (clientHeight - w * height) / 2;

    this.clear(this.fgctx);
    this.clear(this.bgctx)

    ctxs.forEach(ctx => {
      ctx.translate(xT, yT);
      ctx.scale(scaler, scaler)
    });

    this.drawGrid(width, height);

    board.snakes.forEach((snake: bs.Snake) => this.drawSnakeBody(snake));

    this.fgctx.translate(0.5, 0.5);

    board.food.forEach((food: bs.Point) => this.drawFood(food));

    this.fgctx.translate(-0.5, -0.5);

    board.snakes.forEach((snake: bs.Snake) => this.drawImages(snake));

    ctxs.forEach(x => x.setTransform(1, 0, 0, 1, 0, 0));
  }
}
