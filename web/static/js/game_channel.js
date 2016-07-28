import $ from "jquery";
import socket from "./socket";

let gameId = window.gameId;

function init(gameId) {
  let channel = socket.channel(`game:${gameId}`, {});
  let gameBoard = $("#gameBoard");

  function startGame(e) {
    channel.push("start", {})
  }

  function handleTick({html}) {
    gameBoard.html(html);
  }

  $(document).on("click", '[data-js="game.start"]', startGame);

  // replace the board on each tick
  channel.on("tick", handleTick);

  channel.join().
    receive("ok", resp => { console.log("Joined channel", resp) }).
    receive("error", resp => { console.log("Unable to join", resp) });
}

if (typeof gameId !== 'undefined') {
  init(gameId);
}
