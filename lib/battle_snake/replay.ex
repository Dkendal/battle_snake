defmodule BattleSnake.Replay do
end

defmodule BattleSnake.Replay.PlayBack do
  alias __MODULE__
  use GenServer
  require Record

  @attributes [:receiver, :replay_speed, :frames, :topic]
  defstruct(@attributes)
  defmodule Frame, do: defstruct([:data])

  def init(topic, frames, receiver, replay_speed) do
    new_state = struct(__MODULE__,
      topic: topic,
      replay_speed: replay_speed,
      receiver: receiver,
      frames: frames)

    {:ok, new_state}
  end

  def handle_cast(:play, s) do
    {:noreply, s}
  end

  def handle_info(:broadcast, %{frames: []} = s) do
    {:stop, :normal, s}
  end

  def handle_info(:broadcast, s) do
    %PlayBack{
      frames: [frame | rest],
      replay_speed: time,
      receiver: receiver
    } = s

    Process.send_after(self(), :broadcast, time)

    send(receiver, %Frame{data: frame})

    new_state = struct(s, frames: rest)

    {:noreply, new_state}
  end
end

defmodule BattleSnake.Replay.Recorder do
  alias BattleSnake.Replay.Recorder
  alias BattleSnake.GameStateEvent
  alias BattleSnake.GameServer.PubSub
  use GenServer

  #############
  # Type Defs #
  #############

  @type t :: %Recorder{}

  @attributes [:topic, frames: []]
  defstruct @attributes

  defmodule Row do
    require Mnesia.Row

    Mnesia.Row.defrow(
      [:id, :attributes],
      [:id, :attributes])
  end

  ########
  # Init #
  ########

  def init(topic) do
    send(self(), :subscribe_to_topic)
    new_state = %Recorder{topic: topic}
    {:ok, new_state}
  end

  ######################
  # Subscribe to Topic #
  ######################

  def handle_info(:subscribe_to_topic, state) do
    PubSub.subscribe(state.topic)
    {:noreply, state}
  end

  ####################
  # Game State Event #
  ####################

  @doc """
  Incoming Game State Events are appended to the state's "frames" attributes.

  These events are streamed from BattleSnake.GameServer.PubSub after subscribing
  in handle_info(:subscribe_to_topic, state).

  If the event indicates that the game has ended this gen server
  will enable a timeout call.
  """
  @spec handle_info(GameStateEvent.t, t) :: {:noreply, t} | {:noreply, t, timeout}
  def handle_info(%GameStateEvent{data: frame}, state) do
    new_state = update_in(state.frames, &[frame|&1])
    if frame.done? do
      timeout = 100
      {:noreply, new_state, timeout}
    else
      {:noreply, new_state}
    end
  end

  ###########
  # Timeout #
  ###########

  @doc """
  Timeout handler, started from handle_info(game_state_event, t).

  Once the timeout has expired write the recording to disk and hibernate the
  recorder.
  """
  def handle_info(:timeout, state) do
    :ok = %Row{id: state.topic, attributes: [recorder: state]}
    |> Row.struct2record
    |> Mnesia.dirty_write

    {:noreply, state, :hibernate}
  end

  #####################
  # Private Functions #
  #####################
end

defmodule BattleSnake.Replay.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Registry, [:unique, BattleSnake.Replay.Registry], [id: BattleSnake.Replay.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
