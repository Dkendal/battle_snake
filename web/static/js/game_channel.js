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

  function stopGame(e) {
    channel.push("stop", {})
  }

  function nextTurn(e) {
    channel.push("next", {})
  }

  function prevTurn(e) {
    channel.push("prev", {})
  }

  function replay(e) {
    channel.push("replay", {})
  }

  function handleTick({html}) {
    gameBoard.html(html);
  }

  function keydownHandler(event) {
    switch (event.key) {
      case "r":
        startGame(event);
        break;
      case "R":
        replay(event);
        break;
      case " ":
        pauseGame(event);
        break;
      case "q":
        stopGame(event);
        break;
      case "j":
        nextTurn(event);
        break;
      case "ArrowRight":
        nextTurn(event);
        break;
      case "k":
        prevTurn(event);
        break;
      case "ArrowLeft":
        prevTurn(event);
        break;
    }
  }

  $(document).on("click", '[data-js="game.start"]', startGame);
  $(document).on("click", '[data-js="game.pause"]', pauseGame);
  $(document).on("click", '[data-js="game.stop"]', stopGame);
  $(document).on("click", '[data-js="game.next"]', nextTurn);
  $(document).on("click", '[data-js="game.prev"]', prevTurn);
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
