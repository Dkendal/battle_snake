defmodule BattleSnake.GameServer do
  use GenServer

  # Client

  def start_link({_, _, _} = state) do
    GenServer.start_link(__MODULE__, {:suspend, state})
  end

  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def stop_game(pid, _)

  # Server (callbacks)

  # Calls
  def handle_call(:pause, from, {:cont, state}) do
    {:reply, :ok, {:suspend, state}}
  end

  def handle_call(:resume, from, {:suspend, state}) do
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
    if done?(state) do
      {:noreply, {:halted, state}}
    else
      tick(state)
      {:noreply, {:cont, state}}
    end
  end

  def handle_info(:tick, {:suspend, state}) do
    {:noreply, {:suspend, state}}
  end

  def handle_info(:tick, {:halted, state}) do
    {:noreply, {:halted, state}}
  end

  # Private

  defp delay({_, _, opts}) do
    Dict.fetch!(opts, :delay)
  end

  defp tick(state) do
    Process.send_after(self(), :tick, delay(state))
  end

  defp next_turn({world, reducer, opts}) do
    world = reducer.(world)
    {world, reducer, opts}
  end

  # check if the game is over
  def done?({world, _, opts}) do
    fun = Dict.fetch!(opts, :objective)
    fun.(world)
  end
end
