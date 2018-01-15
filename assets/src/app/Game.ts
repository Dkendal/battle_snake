import 'phoenix_html';

import './Game.css';

import {Game} from 'elm/Game';

import css from '../css-variables';
import {GameBoard} from '../GameBoard';
import {embedApp} from '../utils';

const colorPallet = new Map<string, string>(Object.entries(css));

document.addEventListener('DOMContentLoaded', () => {
  const gameAppConfig = {
    websocket: `ws://${window.location.host}/socket/websocket`,
  };

  embedApp('Game', Game, gameAppConfig).map((program: any) => {
    let gameBoard: GameBoard;
    let gameState: GameState;

    window.addEventListener('resize', () => {
      requestAnimationFrame(() => {
        gameBoard.draw(gameState.board);
      });
    });

    program.ports.render.subscribe(({content}: {content: GameState}) => {
      gameState = content;

      if (!gameBoard) {
        const id = gameState.board.gameId;
        const node = document.getElementById(id);

        if (!node) {
          throw new Error(`could not find an element with id ${id}`);
        }

        gameBoard = new GameBoard(node, colorPallet);
      }

      requestAnimationFrame(() => {
        gameBoard.draw(gameState.board);
      });
    });
  });
});
