defmodule Bs.Game do
  alias Bs.Game.PubSub
  alias Bs.Game.Server

  use GenServer

  defdelegate(handle_call(request, from, state), to: Server)
  defdelegate(handle_cast(request, state), to: Server)
  defdelegate(handle_info(request, state), to: Server)
  defdelegate(init(args), to: Server)
  defdelegate(subscribe(name), to: PubSub)

  @supervisor Bs.Game.Supervisor
  @registry Bs.Game.Registry

  @moduledoc """
  The Game is a GenServer that handles running a single Bs match.
  """

  defguard is_id(id) when is_binary(id)

  def start_link(args, opts \\ [])

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get_game_state(pid) when is_pid(pid) do
    GenServer.call(pid, :get_game_state)
  end

  def next(pid) when is_pid(pid) do
    GenServer.call(pid, :next)
  end

  def pause(pid) when is_pid(pid) do
    GenServer.call(pid, :pause)
  end

  def prev(pid) when is_pid(pid) do
    GenServer.call(pid, :prev)
  end

  def resume(pid) when is_pid(pid) do
    GenServer.call(pid, :resume)
  end

  def reset(pid) when is_pid(pid) do
    GenServer.cast(pid, :reset)
  end

  def dispatch(id, fun) when is_id(id) do
    Registry.dispatch(@registry, id, fun)
  end

  def start(id) when is_id(id) do
    Supervisor.start_child(@supervisor, [id, [name: name(id)]])
  end

  def find_or_start(id) when is_id(id) do
    case start(id) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      x -> x
    end
  end

  def find(id) when is_id(id) do
    Registry.lookup(@registry, id)
  end

  def find_or_start!(id) when is_id(id) do
    {:ok, pid} = find_or_start(id)
    pid
  end

  defp name(id) do
    {:via, Registry, {@registry, id}}
  end
end
