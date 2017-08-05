import Mousetrap from "mousetrap";
import socket from "../socket";
import "../empties/modal";

interface TickResponse {
  content: string;
}

const logError = (resp: string) => {
  console.error("Unable to join", resp);
};

const init = (gameId: string) => {
  if (typeof gameId === "undefined") {
    return;
  }

  const boardViewerChannel = socket.channel(`spectator:html:${gameId}`, {});
  const gameAdminChannel = socket.channel(`game_admin:${gameId}`);

  boardViewerChannel.on("tick", ({ content }: TickResponse) => {
    const node = document.getElementById("board-viewer");

    if (!node) return;

    node.innerHTML = content;
  });

  boardViewerChannel.join().receive("error", logError);

  gameAdminChannel.join().receive("error", logError);

  const cmd = (request: string) => {
    console.log(request);
    gameAdminChannel
      .push(request)
      .receive("error", (e: Error) =>
        console.error(`push "${request}" failed`, e)
      );
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
