import {Test} from 'elm/Test';
import {GameBoard} from '../game_board';
import css from '../css-variables';

const colorPallet = new Map<string, string>(Object.entries(css));

const test = Test.fullscreen();

test.ports.render.subscribe(({id, world}) => {
  const timer = window.setInterval(callback, 1);
  const clearInterval = () => window.clearInterval(timer);

  window.setTimeout(clearInterval, 100);

  function callback() {
    const canvas = document.getElementById(id);

    if (!canvas) {
      return;
    }

    clearInterval();

    if (!(canvas instanceof HTMLCanvasElement)) {
      const msg = `Expected ${canvas} to be of type HTMLCanvasElement`
      console.error(msg, canvas, new Error());
      return;
    }

    const ctx = canvas.getContext('2d');

    if (!ctx) {
      console.error('ctx was null', new Error());
      return
    }

    const board = new GameBoard(ctx, colorPallet);

    board.draw(world);
  }
});
