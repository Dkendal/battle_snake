import "phoenix_html"
import $ from "jquery";
import * as BS from "./battle_snake"

const BattleSnake = Object.assign(window.BattleSnake, BS);
window.BattleSnake = BattleSnake;

if ($("#board-viewer")) {
  const gameId = window.BattleSnake.gameId;
  window.BattleSnake.BoardViewer.init(gameId);
}
