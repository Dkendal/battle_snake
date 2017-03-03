import "phoenix_html"
import $ from "jquery";
import * as BS from "./battle_snake"
(() => {
  if (!$("#board-viewer").length) {
    return;
  }

  const BattleSnake = Object.assign(window.BattleSnake, BS);
  window.BattleSnake = BattleSnake;

  if (window.BattleSnake.isReplay) {
  }
  else{
    const gameId = window.BattleSnake.gameId;
    window.BattleSnake.Spectator.init(gameId);
  }
})();
