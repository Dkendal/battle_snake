const bg = "black";

type Ctx = CanvasRenderingContext2D;
type Image = HTMLImageElement;

function noop() { }

const gutter = 0.1;
const unit = 1 - gutter * 2;
const foodColor = "red";
const coordCache: WeakMap<bs.Snake, Array<bs.Point>> = new WeakMap();

function add([x0, x1]: bs.Point, [y0, y1]: bs.Point): bs.Point {
  return [x0 + y0, x1 + y1];
}

function mul([x0, x1]: bs.Point, s: number): bs.Point {
  return [x0 * s, x1 * s];
}

function div(a: bs.Point, s: number): bs.Point {
  return mul(a, 1 / s)
}

function sub(a: bs.Point, b: bs.Point): bs.Point {
  return add(a, mul(b, -1))
}

function eq(a: bs.Point, b: bs.Point): boolean {
  return a[0] === b[0] && a[1] === b[1];
}

function uniq(s: bs.Point[]): bs.Point[] {
  return s.reduce(([y, ...s], x) => {
    if (!eq(y, x)) {
      return [x, y, ...s];
    }
    return [y, ...s];
  }, [s[0]])
    .reverse();
}

function coords(snake: bs.Snake): bs.Point[] {
  const coords = coordCache.get(snake)

  if (coords) {
    return coords;
  }

  const arr = uniq(snake.coords);

  coordCache.set(snake, arr);

  return arr;
}

// Add an interpolated point between every point in points.
function smooth(points: bs.Point[]) {
  return points.reduce(
    ([b, ...s], a) => {
      const mean = div(add(a, b), 2);
      return [a, mean, b, ...s];
    },
    [points[0]]);
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

function loadImage(id: string, color: string): Promise<Image> {
  const link = <HTMLLinkElement | null>document.getElementById(id);

  if (!link || !link.href) {
    return Promise.reject('no href on link');
  }

  return get(link.href).then((svg: SVGSVGElement) => {
    return svg2image(svg, color);
  });
}

export class Board {
  private readonly bgctx: Ctx;
  private readonly fgctx: Ctx;
  private readonly height: number;
  private readonly width: number;
  private readonly images = new Map();

  constructor(fgctx: Ctx, bgctx: Ctx, width: number, height: number) {
    this.bgctx = bgctx;
    this.fgctx = fgctx;
    this.width = width;
    this.height = height;
  }

  drawGrid(width: number, height: number) {
    this.clear(this.bgctx);

    this.bgctx.fillStyle = bg;

    for (let i = 0; i < width; i++) {
      for (let j = 0; j < height; j++) {
        this.bgctx.fillRect(i + gutter, j + gutter, unit, unit);
      }
    }

    delete this.drawGrid;
    this.drawGrid = noop;
  }

  getImage(id: string, color: string): Image {
    const key = `${id}-${color}`

    const image = this.images.get(key);

    if (image) {
      return image;
    }

    loadImage(id, color).then((image: Image) => {
      this.images.set(key, image);
    });

    return new Image();
  }

  headImage(snake: bs.Snake): Image {
    const id = `snake-head-${snake.headType}`;
    return this.getImage(id, snake.color);
  }

  tailImage(snake: bs.Snake): Image {
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

  drawImage(image: Image, h0: bs.Point, h1: bs.Point) {
    const ctx = this.fgctx;

    const offset = unit / 2 * -1;

    const v = sub(h0, h1);

    const [a0, a1] = add([0.5, 0.5], // translate to centre of point
      sub(h0, // move to coordinate
        div(v, 10))); // move to border of path

    ctx.save();

    ctx.translate(a0, a1);

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
    ctx.beginPath();
    ctx.fillStyle = foodColor;
    ctx.arc(x, y, unit / 2, 0, 2 * Math.PI);
    ctx.fill();
  }

  clear(ctx: Ctx) {
    ctx.clearRect(0, 0, this.width, this.height);
  }

  draw(board: bs.Board) {
    const ctxs = [this.bgctx, this.fgctx];

    const width = Math.floor(this.width / board.width);
    const height = Math.floor(this.height / board.height);

    this.clear(this.fgctx);

    ctxs.forEach(x => x.scale(width, height));

    this.drawGrid(width, height);

    board.snakes.forEach((snake: bs.Snake) => this.drawSnakeBody(snake));

    this.fgctx.translate(0.5, 0.5);

    board.food.forEach((food: bs.Point) => this.drawFood(food));

    this.fgctx.translate(-0.5, -0.5);

    board.snakes.forEach((snake: bs.Snake) => this.drawImages(snake));

    ctxs.forEach(x => x.setTransform(1, 0, 0, 1, 0, 0));
  }
}
