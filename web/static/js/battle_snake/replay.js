import Mousetrap from "mousetrap";
import socket from "../socket"
import "../empties/modal";

const logError = resp => {
  console.error("Unable to join", resp)
};

const init = (gameId) => {
  if(typeof gameId === "undefined") {
    return;
  }

  const replayChannel = socket.channel(`replay:html:${gameId}`, {});

  replayChannel.on("tick", ({content}) => {
    document.getElementById("board-viewer").innerHTML = content;
  });

  replayChannel.
    join().
    receive("error", logError);

  const cmd = (request) => {
    console.log(request);
    replayChannel.
      push(request).
      receive("error", e => console.error(`push "${request}" failed`, e));
  };
  Mousetrap.bind(["q"], () => cmd("stop"));
  Mousetrap.bind(["h", "left"], () => cmd("prev"));
  Mousetrap.bind(["j", "up"], () => cmd("resume"));
  Mousetrap.bind(["k", "down"], () => cmd("pause"));
  Mousetrap.bind(["l", "right"], () => cmd("next"));
};

export default {
  init
};
