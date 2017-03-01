import "phoenix_html"
import socket from "./socket"
import $ from "jquery";
import Mousetrap from "mousetrap";

const gameId = window.BattleSnake.gameId;
const logError = resp => { console.error("Unable to join", resp) };

const init = () => {
  const boardViewerChannel = socket.channel(`spectator:html:${gameId}`, {contentType: "html"});
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
}

if(typeof gameId !== "undefined") {
  init();
}
