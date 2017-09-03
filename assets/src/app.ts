import "./app.css";
import "phoenix_html";
import { GameApp } from "elm/GameApp";
import { embedApp } from "./utils";
import { GameBoard } from "./game_board";
import css from './css-variables'

const colorPallet = new Map<string, string>(Object.entries(css));

document.addEventListener("DOMContentLoaded", () => {
  const gameAppConfig = {
    websocket: `ws://${window.location.host}/socket/websocket`
  };

  embedApp('GameApp', GameApp, gameAppConfig).map((program) => {
    program.ports.mount.subscribe(({ fgId, bgId }) => {
      const fg = <HTMLCanvasElement>document.getElementById(fgId);
      const bg = <HTMLCanvasElement>document.getElementById(bgId);

      const [fgctx, bgctx] = [fg, bg].map(x => x && x.getContext("2d"));

      if (!fgctx || !bgctx) {
        return;
      }

      const board = new GameBoard(fgctx, bgctx, colorPallet);

      program.ports.draw.subscribe(({ content }) => {
        requestAnimationFrame(() => {
          fg.width = fg.clientWidth;
          fg.height = fg.clientHeight;
          bg.width = fg.clientWidth;
          bg.height = fg.clientHeight;
          board.draw(content)
        });
      })
    })
  });
});
