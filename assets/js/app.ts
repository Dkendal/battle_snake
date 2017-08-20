import "css/app";
import "phoenix_html";
import { GameApp } from "elm/GameApp";
import { embedApp } from "./utils";
import { GameBoard } from "./game_board";

const colorPallet = new Map<string, string>([
  ['background', '#999'],
  ['food', '#f06a53'],
]);

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

      const board = new GameBoard(fgctx, bgctx, fg.width, fg.height, colorPallet);

      program.ports.draw.subscribe(({ content }) => {
        requestAnimationFrame(() => board.draw(content));
      })
    })
  });
});
