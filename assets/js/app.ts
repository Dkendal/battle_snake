import "css/app";
import "phoenix_html";
import socket from "./socket";
import Mousetrap from "mousetrap";
import { Spectator } from "./channels";
import { GameBoard } from "./game_board";

const logger = console.error.bind(console);
const width = 1920;
const height = 1920;

const colorPallet = new Map<string, string>([
  ['background', '#999'],
  ['food', '#f06a53'],
]);

class Config {
  isReplay: boolean = false;
  gameId: string = "";
  gameAdminAvailableRequests: string[] = [];
}

function loadConfig(): Config {
  const elem = document.getElementById("battle-snake-config");

  if (!elem) {
    return new Config();
  }

  return <Config>JSON.parse(elem.innerText);
}

function joinAdminChannel(gameId: string) {
  const channel = socket.channel(`game_admin:${gameId}`);

  channel.join().receive("error", logger);

  const cmd = (event: string) => {
    channel.push(event, {}).receive("error", logger);
  };

  Mousetrap.bind(["q"], cmd.bind(null, "stop"));
  Mousetrap.bind(["h", "left"], cmd.bind(null, "prev"));
  Mousetrap.bind(["j", "up"], cmd.bind(null, "resume"));
  Mousetrap.bind(["k", "down"], cmd.bind(null, "pause"));
  Mousetrap.bind(["l", "right"], cmd.bind(null, "next"));
  Mousetrap.bind("R", cmd.bind(null, "replay"));
}

(() => {
  const gameboardContainer = document.getElementById("game-board");

  if (!gameboardContainer) {
    return;
  }

  const fg = document.createElement("canvas");
  const bg = document.createElement("canvas");

  [bg, fg].forEach(canvas => {
    canvas.width = width;
    canvas.height = height;
    gameboardContainer.appendChild(canvas);
  });

  const [fgctx, bgctx] = [fg, bg].map(x => x.getContext("2d"));

  if (!fgctx || !bgctx) {
    return;
  }

  const config = loadConfig();
  const gameId = config.gameId;
  const board = new GameBoard(fgctx, bgctx, width, height, colorPallet);
  const spectator = new Spectator(gameId);

  spectator.onTick = (state: bs.Board) => {
    requestAnimationFrame(() => {
      board.draw(state);
    });
  };

  spectator.join()

  joinAdminChannel(gameId);
})();
