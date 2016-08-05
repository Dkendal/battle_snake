defmodule BattleSnake.GameServer do
  use GenServer

  # Client

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def start_game(pid) do
    GenServer.call(pid, :start_game)
  end

  def pause_game(pid, _)
  def stop_game(pid, _)

  # Server (callbacks)

  # Calls
  def handle_call(:start_game, from, state) do
    {world, _, opts} = state

    tick(state)

    {:reply, world, state}
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  # Casts

  def handle_cast(request, state) do
    super(request, state)
  end

  def handle_info(:tick, state) do
    {world, f, opts} = state
    world = f.(world)
    state = {world, f, opts}

    tick(state)

    {:noreply, state}
  end

  # Private

  defp delay({_, _, opts}) do
    opts[:delay]
  end

  defp tick(state) do
    Process.send_after(self(), :tick, delay(state))
  end
end
