import {Test} from 'elm/Test';
import {GameBoard} from '../GameBoard';
import css from '../css-variables';

const colorPallet = new Map<string, string>(Object.entries(css));

const test = Test.fullscreen();

test.ports.render.subscribe(world => {
  const id = world.gameId;
  const inverval = window.setInterval(callback, 20);

  const timeout = window.setTimeout(() => {
    console.error(
      `Couldn't find an HTMLCanvasElement with id ${id}`,
      new Error()
    );

    window.clearInterval(inverval);
  }, 100);

  function callback() {
    const node = document.getElementById(id);

    if (!node) {
      return;
    }

    window.clearInterval(inverval);
    window.clearTimeout(timeout);

    const canvas = document.createElement('canvas');
    node.appendChild(canvas);

    const ctx = (canvas.getContext('2d') as any) as Ctx;

    if (!ctx) {
      console.error('ctx was null', new Error());
      return;
    }

    const board = new GameBoard(ctx, colorPallet);

    board.draw(world);
  }
});
