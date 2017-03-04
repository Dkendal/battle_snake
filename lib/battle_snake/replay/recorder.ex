defmodule BattleSnake.Replay.Recorder do
  alias BattleSnake.GameServer.PubSub
  alias BattleSnake.GameStateEvent
  alias BattleSnake.Replay
  alias BattleSnake.Replay.Recorder
  use GenServer

  #############
  # Type Defs #
  #############

  @type t :: %Recorder{}

  @attributes [:topic, frames: []]
  defstruct @attributes

  ##############
  # Start Link #
  ##############

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  ########
  # Init #
  ########

  def init(topic) do
    send(self(), :subscribe_to_topic)
    new_state = %Recorder{topic: topic}
    {:ok, new_state}
  end

  #########################
  # Handle Info Callbacks #
  #########################

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
      timeout = 2000
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
    require Logger
    Logger.info("writing replay for #{state.topic}")

    rewound_state = update_in(state.frames, &Enum.reverse/1)
    created_at = DateTime.utc_now()
    bin = :erlang.term_to_binary(rewound_state, [:compressed])
    attributes = [bin: bin, created_at: created_at]

    :ok = %Replay{id: state.topic, attributes: attributes}
    |> Replay.struct2record
    |> Mnesia.dirty_write

    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    require Logger
    Logger.debug "Recorder terminated with reason #{reason}"
    super(reason, state)
  end

  #####################
  # Private Functions #
  #####################
end
