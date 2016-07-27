import socket from "./socket";

let game_id = window.game_id;

if (game_id) {
  let channel = socket.channel(`game:${game_id}`, {});

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) });
}
