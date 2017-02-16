// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".
import socket from "./socket"
import $ from "jquery";
import Mousetrap from "mousetrap";
import "./empties/modal";

const gameId = window.BattleSnake.gameId;
const logError = resp => { console.error("Unable to join", resp) };

const init = () => {
  const boardViewerChannel = socket.channel(`board_viewer:${gameId}`, {contentType: "html"});
  const gameAdminChannel = socket.channel(`game_admin:${gameId}`);

  boardViewerChannel.on("tick", ({content}) => {
    $("#board-viewer").html(content);
  });

  boardViewerChannel.
    join().
    receive("error", logError);

  gameAdminChannel.
    join().
    receive("error", logError);

  const cmd = (request) => {
    console.log(request);
    gameAdminChannel.
      push(request).
      receive("error", e => console.error(`push "${request}" failed`, e));
  };

  Mousetrap.bind(["q"], () => cmd("stop"));
  Mousetrap.bind(["h", "left"], () => cmd("prev"));
  Mousetrap.bind(["j", "up"], () => cmd("resume"));
  Mousetrap.bind(["k", "down"], () => cmd("pause"));
  Mousetrap.bind(["l", "right"], () => cmd("next"));
  Mousetrap.bind("R", () => cmd("replay"));
}

if(typeof gameId !== "undefined") {
  init();
}
