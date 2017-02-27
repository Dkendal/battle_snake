defmodule BattleSnake.GameServer.Server do
  alias BattleSnake.GameForm
  alias BattleSnake.GameServer.State
  alias BattleSnake.GameServer.PubSub

  import State
  use GenServer

  ########
  # Init #
  ########

  def init({:ok, value}),
    do: init(value)

  def init({:error, reason}),
    do: {:stop, reason}

  def init(game_form_id) when is_binary(game_form_id) do
    GameForm
    |> Mnesia.Repo.dirty_find(game_form_id)
    |> init
  end

  def init(%GameForm{} = game_form) do
    game_form
    |> GameForm.reload_game_server_state
    |> init
  end

  def init(%State{} = state) do
    state = State.on_start(state)
    do_reply({:ok, state})
  end

  #########################
  # Handle Call Callbacks #
  #########################

  ##################
  # Get Game State #
  ##################

  @spec handle_call(:get_game_state, pid, State.t) :: {:reply, State.t, State.t}
  def handle_call(:get_game_state, _from, state) do
    {:reply, state, state}
  end

  ##############
  # Get Status #
  ##############

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  ########
  # Next #
  ########

  def handle_call(:next, _from, state) do
    state =
      case state.status do
        :halted ->
          state

        _status ->
          state
          |> State.step
          |> State.suspend!
      end

    do_reply({:reply, :ok, state})
  end

  def handle_call(:pause, _from, state) do
    state =
      case state.status do
        :cont ->
          suspend!(state)
        _status ->
          state
      end

    do_reply({:reply, :ok, state})
  end

  ########
  # Prev #
  ########

  def handle_call(:prev, _from, state) do
    state = state
    |> State.step_back
    |> suspend!

    do_reply({:reply, :ok, state})
  end

  ##########
  # Resume #
  ##########

  def handle_call(:resume, _from, state) do
    state =
      case state.status do
        :suspend ->
          send(self(), :tick)
          cont!(state)

        _status ->
          state
      end

    do_reply({:reply, :ok, state})
  end

  ##########
  # Replay #
  ##########

  def handle_call(:replay, _from, state) do
    send(self(), :tick)
    state = state
    |> load_history
    |> replay!
    do_reply({:reply, :ok, state})
  end

  def handle_call(request, from, state) do
    super(request, from, state)
  end

  #########################
  # Handle Cast Callbacks #
  #########################

  def handle_cast(request, state) do
    super(request, state)
  end

  #########################
  # Handle Info Callbacks #
  #########################

  #############
  # Get State #
  #############

  def handle_info(:get_state, state) do
    {:reply, state, state.status}
  end

  ########
  # Tick #
  ########

  def handle_info(:tick, state) do
    state =
      case state.status do
        :cont -> tick_cont(state)
        :replay -> State.step(state)
        _ -> state
      end
    do_reply({:noreply, state})
  end

  def handle_info(request, state) do
    super(request, state)
  end

  ###################
  # Private Methods #
  ###################

  defp tick_cont(state) do
    delay = State.delay(state)

    Process.send_after(self(), :tick, delay)

    state = State.step(state)

    if State.done?(state) do
      state = State.on_done(state)
      halted!(state)
    else
      cont!(state)
    end
  end

  defp broadcast(state) do
    topic = state.game_form_id
    PubSub.broadcast(topic, tick_event(state))
    state
  end

  defp tick_event(state) do
    %State.Event{name: :tick, data: state}
  end

  defp do_reply({_, state} = reply) do
    broadcast(state)
    reply
  end

  defp do_reply({_, _, state} = reply) do
    broadcast(state)
    reply
  end
end
