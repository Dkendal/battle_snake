import "css/app"
import "phoenix_html"
import $ from "jquery";
import * as BS from "./battle_snake"

(() => {
  if (!$("#board-viewer").length) {
    return;
  }

  const BattleSnake = Object.assign(window.BattleSnake, BS);
  window.BattleSnake = BattleSnake;
  const gameId = window.BattleSnake.gameId;

  if (window.BattleSnake.isReplay) {
    window.BattleSnake.Replay.init(gameId);
  }
  else{
    window.BattleSnake.Spectator.init(gameId);
  }
})();
