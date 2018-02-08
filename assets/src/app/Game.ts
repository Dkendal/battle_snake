import "phoenix_html";

import "./Game.css";

import { Game } from "elm/Game";

document.addEventListener("DOMContentLoaded", () => {
  const node = document.getElementById("gameapp");

  if (!node) return;

  const websocket = `ws://${window.location.host}/socket/websocket`;
  const gameid = node.dataset.gameid;

  if (!gameid) return;

  Game.embed(node, {
    gameid,
    websocket
  });
});
