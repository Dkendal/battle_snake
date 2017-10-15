defmodule Bs.Game.Server do
  require Logger

  alias Bs.Game.PubSub
  alias Bs.GameState
  alias Bs.World.Factory

  import GameState
  use GenServer

  def init(id) when is_binary(id) do
    send(self(), {:after_init, id})
    {:ok, :no_state}
  end

  def init(%GameState{game_form_id: game_form_id} = state)
      when is_integer(game_form_id) do
    do_reply({:ok, state})
  end

  def handle_call(:get_game_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:get_status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:next, _from, state) do
    state =
      case state.status do
        :halted ->
          state

        _status ->
          state
          |> GameState.step()
          |> GameState.suspend!()
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

  def handle_call(:prev, _from, state) do
    state =
      state
      |> GameState.step_back()
      |> suspend!

    do_reply({:reply, :ok, state})
  end

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

  def handle_call(request, from, state) do
    Logger.error(
      Exception.format(
        "unmatched call to Bs.Game.Server",
        request,
        System.stacktrace()
      )
    )

    super(request, from, state)
  end

  def handle_cast(request, state) do
    Logger.error(
      Exception.format(
        "unmatched cast to Bs.Game.Server",
        request,
        System.stacktrace()
      )
    )

    super(request, state)
  end

  def handle_info({:after_init, id}, :no_state) do
    id = String.to_integer(id)

    game_form = BsRepo.get!(BsRepo.GameForm, id)

    delay = game_form.delay

    world = Factory.build(game_form)

    singleplayer = fn world -> length(world.snakes) <= 0 end

    multiplayer = fn world -> length(world.snakes) <= 1 end

    objective =
      case game_form.game_mode do
        "singleplayer" -> singleplayer
        "multiplayer" -> multiplayer
      end

    state = %Bs.GameState{
      delay: delay,
      game_form: game_form,
      game_form_id: id,
      objective: objective,
      world: world
    }

    do_reply({:noreply, state})
  end

  def handle_info(:get_state, state) do
    {:reply, state, state.status}
  end

  def handle_info(:tick, state) do
    state =
      case state.status do
        :cont -> tick_cont(state)
        _ -> state
      end

    do_reply({:noreply, state})
  end

  @doc """
  When the game is complete the result should be completed.

  TODO save the result.
  """
  def handle_info(:game_done, state) do
    {:noreply, state}
  end

  def handle_info(request, state) do
    super(request, state)
  end

  defp tick_cont(state) do
    delay = GameState.delay(state)

    Process.send_after(self(), :tick, delay)

    state = GameState.step(state)

    if state.done? do
      halted!(state)
    else
      cont!(state)
    end
  end

  defp broadcast(%{game_form_id: topic} = state) when is_integer(topic) do
    ignored_fields = [:hist, :objective]

    broadcast_state = Map.drop(state, ignored_fields)

    PubSub.broadcast(topic, {:tick, broadcast_state})

    state
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
