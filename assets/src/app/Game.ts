import './Game.css';
import 'phoenix_html';
import {Game} from 'elm/Game';
import {embedApp} from '../utils';
import {GameBoard} from '../GameBoard';
import css from '../css-variables';

const colorPallet = new Map<string, string>(Object.entries(css));

document.addEventListener('DOMContentLoaded', () => {
  const gameAppConfig = {
    websocket: `ws://${window.location.host}/socket/websocket`,
  };

  embedApp('Game', Game, gameAppConfig).map(program => {
    let board: GameBoard;
    let canvas: HTMLCanvasElement;

    program.ports.render.subscribe(world => {
      const id = world.gameId;

      if (!board) {
        const node = document.getElementById(id);

        if (!(node instanceof HTMLCanvasElement)) {
          throw new Error(`Expected ${canvas} to be of type HTMLCanvasElement`);
        }

        canvas = node;

        const ctx = canvas.getContext('2d') as any as Ctx;

        if (!ctx) {
          throw new Error('ctx was null');
        }

        board = new GameBoard(ctx, colorPallet);
      }

      requestAnimationFrame(() => {
        canvas.width = canvas.clientWidth;
        canvas.height = canvas.clientHeight;
        board.draw(world);
      });
    });
  });
});
