import {Test} from 'elm/Test';
import {GameBoard} from '../GameBoard';
import css from '../css-variables';
import './Test.css';

const colorPallet = new Map<string, string>(Object.entries(css));

const test = Test.fullscreen({
  websocket: `ws://${window.location.host}/socket/websocket`,
});

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

    const board = new GameBoard(node, colorPallet);

    board.draw(world);
  }
});
