import Mousetrap from "mousetrap";
import $ from "jquery";
import socket from "../socket"
import "../empties/modal";

const logError = resp => {
  console.error("Unable to join", resp)
};

const init = (gameId) => {
  if(typeof gameId === "undefined") {
    return;
  }

  const boardViewerChannel = socket.channel(`board_viewer:${gameId}`, {contentType: "html"});
  const gameAdminChannel = socket.channel(`game_admin:${gameId}`);

  boardViewerChannel.on("tick", ({content}) => {
    $("#board-viewer").html()
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
};

export default {
  init
};
