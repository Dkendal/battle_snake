import $ from "jquery";
import socket from "./socket";

let gameId = window.gameId;

function init(gameId) {
  let channel = socket.channel(`game:${gameId}`, {});
  let gameBoard = $("#gameBoard");

  function pauseGame(e) {
    channel.push("pause", {})
  }

  function startGame(e) {
    channel.push("start", {})
  }

  function handleTick({html}) {
    gameBoard.html(html);
  }

  function keydownHandler(event) {
    switch (event.key) {
      case "r":
        startGame(event);
        break;
      case " ":
        pauseGame(event);
        break;
    }
  }

  $(document).on("click", '[data-js="game.start"]', startGame);
  $(document).on("click", '[data-js="game.pause"]', pauseGame);
  $(document).on("keydown", "body", keydownHandler);

  // replace the board on each tick
  channel.on("tick", handleTick);

  channel.join().
    receive("ok", resp => { console.log("Joined channel", resp) }).
    receive("error", resp => { console.log("Unable to join", resp) });
}

if (typeof gameId !== 'undefined') {
  init(gameId);
}
