defmodule BattleSnake.Replay.PlayBack do
  use GenServer
  alias BattleSnake.GameServer.PubSub
  alias BattleSnake.Replay.Recorder.Row
  require Record
  require Row

  @attributes [:receiver, :replay_speed, :frames, :topic]
  defstruct(@attributes)
  defmodule Frame, do: defstruct([:data])

  ##############
  # Start Link #
  ##############

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  ########
  # Init #
  ########

  def init(game_id) do
    alias BattleSnake.Replay.Recorder.Row

    tab = Row
    [row] = Mnesia.dirty_read(tab, game_id)
    attributes = Row.row(row, :attributes)
    bin = Keyword.fetch!(attributes, :bin)
    recorder = :erlang.binary_to_term(bin)
    frames = recorder.frames
    topic = "replay:#{game_id}"
    replay_speed = 50
    init(topic, frames, self(), replay_speed)
  end

  def init(topic, frames, receiver, replay_speed) do
    new_state = struct(__MODULE__,
      topic: topic,
      replay_speed: replay_speed,
      receiver: receiver,
      frames: frames)

    {:ok, new_state}
  end

  #########################
  # Handle Call Callbacks #
  #########################

  def handle_cast(:resume, state) do
    send(self(), :broadcast)
    {:noreply, state}
  end

  #########################
  # Handle Info Callbacks #
  #########################

  def handle_info(:broadcast, %{frames: []} = state) do
    {:stop, :normal, state}
  end

  def handle_info(:broadcast, state) do
    [frame | rest] = state.frames
    time = state.replay_speed
    topic = state.topic

    Process.send_after(self(), :broadcast, time)

    frame = %Frame{data: frame}
    topic = topic

    require Logger
    Logger.debug "broadcasting to #{topic}"

    PubSub.broadcast(topic, frame)

    new_state = put_in state.frames, rest
    {:noreply, new_state}
  end
end
