defmodule BattleSnake.GameServer.Server do
  alias BattleSnake.GameForm
  alias BattleSnake.GameServer.State
  alias BattleSnake.GameServer.PubSub

  import State
  use GenServer

  def init({:ok, value}), do: init(value)
  def init({:error, reason}), do: {:stop, reason}

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
    state
    |> State.on_start

    {:ok, state}
    |> do_reply
  end

  @spec handle_call(:get_game_state, pid, State.t) :: {:reply, State.t, State.t}
  def handle_call(:get_game_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:next, _from, state) do
    case state.status do
      :halted ->
        {:reply, :ok, state}

      _ ->
        state = State.step(state)
        {:reply, :ok, State.suspend!(state)}
    end
    |> do_reply
  end

  def handle_call(:pause, _from, state) do
    case state.status do
      :cont ->
        {:reply, :ok, suspend!(state)}

      _status ->
        {:reply, :ok, state}
    end
    |> do_reply
  end

  def handle_call(:prev, _from, state) do
    case state.status do
      _status ->
        state = state
        |> State.step_back()
        {:reply, :ok, suspend!(state)}
    end
    |> do_reply
  end

  def handle_call(:resume, _from, state) do
    case state.status do
      :suspend ->
        tick(state)
        {:reply, :ok, cont!(state)}

      _status ->
        {:reply, :ok, state}
    end
    |> do_reply
  end

  def handle_call(:replay, _from, state) do
    state = load_history(state)
    tick(state)
    {:reply, :ok, replay!(state)}
    |> do_reply
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  def handle_cast(request, state) do
    super(request, state)
  end

  def handle_info(:get_state, state) do
    {:reply, state, state.status}
  end

  def handle_info(:tick, state) do
    case state.status do
      :cont ->
        state = State.step(state)
        if State.done?(state) do
          state = State.on_done(state)
          {:noreply, halted!(state)}
        else
          tick(state)
          {:noreply, cont!(state)}
        end

      :replay ->
        state= State.step(state)
        tick(state)
        {:noreply, state}

      :halted ->
        {:noreply, state}

      :suspend ->
        {:noreply, state}
    end
    |> do_reply
  end

  def handle_info(request, state) do
    super(request, state)
  end

  defp tick(state) do
    Process.send_after(self(), :tick, State.delay(state))
  end

  def do_reply({_, state} = reply) do
    broadcast(state)
    reply
  end

  def do_reply({_, _, state} = reply) do
    broadcast(state)
    reply
  end

  def tick_event(state) do
    %State.Event{name: :tick, data: state}
  end

  def broadcast(state) do
    topic = state.game_form_id
    PubSub.broadcast(topic, tick_event(state))
    state
  end
end
