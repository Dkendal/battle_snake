import './app.css';
import 'phoenix_html';
import {Game} from 'elm/Game';
import {embedApp} from './utils';
import {GameBoard} from './game_board';
import css from './css-variables';

const colorPallet = new Map<string, string>(Object.entries(css));

document.addEventListener('DOMContentLoaded', () => {
  const gameAppConfig = {
    websocket: `ws://${window.location.host}/socket/websocket`,
  };

  embedApp('Game', Game, gameAppConfig).map(program => {
    program.ports.mount.subscribe((id: string) => {
      const canvas = document.getElementById(id);

      if (!(canvas instanceof HTMLCanvasElement)) {
        throw new Error(`Expected ${canvas} to be of type HTMLCanvasElement`);
      }

      const ctx = canvas.getContext('2d');

      if (!ctx) {
        throw new Error('ctx was null');
      }

      const board = new GameBoard(ctx, colorPallet);

      program.ports.draw.subscribe(({content}) => {
        requestAnimationFrame(() => {
          canvas.width = canvas.clientWidth;
          canvas.height = canvas.clientHeight;
          board.draw(content);
        });
      });
    });
  });
});
