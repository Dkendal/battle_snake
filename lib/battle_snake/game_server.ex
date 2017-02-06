defmodule BattleSnake.GameServer do
  alias __MODULE__
  alias __MODULE__.State
  use GenServer

  import State

  defmodule Command, do: defstruct [:name, :data]

  @type state :: State.t
  @type server :: GenServer.server

  @moduledoc """
  The GameServer is a GenServer that handles running a single BattleSnake match.
  """

  def start_link(state, opts \\ [])

  def start_link(%State{} = state, opts) do
    state = State.on_start(state)
    GenServer.start_link(__MODULE__, state, opts)
  end

  defdelegate get_state(pid), to: GameServer.Client
  defdelegate get_status(pid), to: GameServer.Client
  defdelegate next(pid), to: GameServer.Client
  defdelegate on_change(pid), to: GameServer.Client
  defdelegate on_done(pid), to: GameServer.Client
  defdelegate on_start(pi), to: GameServer.Client
  defdelegate pause(pid), to: GameServer.Client
  defdelegate prev(pid), to: GameServer.Client
  defdelegate resume(pid), to: GameServer.Client
  defdelegate replay(pid), to: GameServer.Client

  defp tick(state) do
    Process.send_after(self(), :tick, State.delay(state))
  end

  # End Client Api

  # Begin Server Callbacks

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
  end

  def handle_call(:on_change, _from, {status, state}) do
    state = State.on_change(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:on_done, _from, {status, state}) do
    state = State.on_done(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:on_start, _from, {status, state}) do
    state = State.on_start(state)
    {:reply, :ok, {status, state}}
  end

  def handle_call(:pause, _from, state) do
    case state.status do
      :cont ->
        {:reply, :ok, put_in(state.status, :suspend)}

      _status ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:prev, _from, state) do
    case state.status do
      :halted ->
        {:reply, :ok, put_in(state.status, :halted)}

      _status ->
        state = state
        |> State.step_back()
        {:reply, :ok, put_in(state.status, :suspend)}
    end
  end

  def handle_call(:resume, _from, state) do
    case state.status do
      :suspend ->
        tick(state)
        {:reply, :ok, put_in(state.status, :cont)}

      _status ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:replay, _from, state) do
    state = load_history(state)
    tick(state)
    {:reply, :ok, replay!(state)}
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
  end

  def handle_info(request, state) do
    super(request, state)
  end

  # End Server Callbacks
end
