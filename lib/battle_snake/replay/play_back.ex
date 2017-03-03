defmodule BattleSnake.Replay.PlayBack do
  use GenServer
  alias __MODULE__
  alias BattleSnake.GameServer.PubSub
  alias BattleSnake.Replay.Recorder.Row
  require Record
  require Row

  @attributes [:receiver, :replay_speed, :frames, :topic]
  defstruct(@attributes)
  defmodule Frame, do: defstruct([:data])

  ########
  # Init #
  ########

  def init(game_id) do
    alias BattleSnake.Replay.Recorder.Row

    tab = Row
    [row] = Mnesia.dirty_read(tab, game_id)
    attributes = Row.row(row, :attributes)
    recorder = Keyword.fetch!(attributes, :recorder)
    frames = recorder.frames
    topic = game_id
    replay_speed = 5
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

  def handle_info(:broadcast, %{frames: []} = s) do
    require Logger
    Logger.debug "End of replay"
    {:stop, :normal, s}
  end

  def handle_info(:broadcast, s) do
    %PlayBack{
      frames: [frame | rest],
      replay_speed: time,
    } = s

    Process.send_after(self(), :broadcast, time)

    frame = %Frame{data: frame}
    topic = "test"
    PubSub.broadcast(topic, frame)
    require Logger
    Logger.debug "broadcasting to #{topic}"

    new_state = struct(s, frames: rest)
    {:noreply, new_state}
  end
end
