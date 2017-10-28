import {Test} from 'elm/Test';
import {GameBoard} from '../game_board';
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
    const canvas = document.getElementById(id);

    if (!canvas) {
      return;
    }

    window.clearInterval(inverval);
    window.clearTimeout(timeout);

    if (!(canvas instanceof HTMLCanvasElement)) {
      const msg = `Expected ${canvas} to be of type HTMLCanvasElement`;
      console.error(msg, canvas, new Error());
      return;
    }

    const ctx = canvas.getContext('2d');

    if (!ctx) {
      console.error('ctx was null', new Error());
      return;
    }

    const board = new GameBoard(ctx, colorPallet);

    board.draw(world);
  }
});
