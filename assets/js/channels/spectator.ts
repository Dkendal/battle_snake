import socket from "../socket";

type OnTick = (board: bs.Board) => void;

export class Spectator {
  private gameId: string;

  onTick: OnTick;

  logger = console.error.bind(console);

  constructor(gameId: string) {
    this.gameId = gameId;
  }

  get name() {
    return `spectator:${this.gameId}`;
  }

  join() {
    const channel = socket.channel(this.name, {});

    channel.on("tick", ({ content }: bs.TickResponse) => {
      this.onTick(content);
    });

    channel.join().receive("error", this.logger);
  }
}

export default Spectator;
