import { Test } from 'elm/Test';
import { GameBoard } from '../game_board';
import css from '../css-variables'

const colorPallet = new Map<string, string>(Object.entries(css));

const test = Test.fullscreen();

test.ports.render.subscribe(({id, world}) => {
  const timer = window.setInterval(callback, 1);

  window.setTimeout(clear, 100);

  function callback() {
    const node = document.getElementById(id);

    if (!node) {
      return
    }

    clear();

    const [fg, bg] = node.querySelectorAll('canvas')

    if (!(fg instanceof HTMLCanvasElement && bg instanceof HTMLCanvasElement)) {
      throw new Error("");
    }

    const fgCtx = fg.getContext("2d");
    const bgCtx = bg.getContext("2d");

    if (!(fgCtx && bgCtx)) {
      throw new Error("");
    }

    const board = new GameBoard(fgCtx, bgCtx, colorPallet);

    console.log(id, world)
    board.draw(world);
  }

  function clear() {
    window.clearInterval(timer);
  }
});
