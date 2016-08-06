defmodule BattleSnake.GameServer do
  use GenServer

  # Client

  def start_link({_, _, _} = state) do
    GenServer.start_link(__MODULE__, {:suspend, state})
  end

  def resume_game(pid) do
    GenServer.call(pid, :resume_game)
  end

  def pause_game(pid) do
    GenServer.call(pid, :pause_game)
  end

  def stop_game(pid, _)

  # Server (callbacks)

  # Calls
  def handle_call(:pause_game, from, {:cont, state}) do
    {:reply, :ok, {:suspend, state}}
  end

  def handle_call(:resume_game, from, {:suspend, state}) do
    tick(state)
    {:reply, :ok, {:cont, state}}
  end

  def handle_call(request, from, state) do
    # Call the default implementation from GenServer
    super(request, from, state)
  end

  # Casts

  def handle_cast(request, state) do
    super(request, state)
  end

  def handle_info(:tick, {:cont, state}) do
    state = next_turn(state)
    tick(state)
    {:noreply, {:cont, state}}
  end

  def handle_info(:tick, {:suspend, state}) do
    {:noreply, {:suspend, state}}
  end

  # Private

  defp delay({_, _, opts}) do
    opts[:delay]
  end

  defp tick(state) do
    Process.send_after(self(), :tick, delay(state))
  end

  defp next_turn({world, reducer, opts}) do
    world = reducer.(world)
    {world, reducer, opts}
  end
end
