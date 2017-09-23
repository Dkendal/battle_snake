defmodule Bs.Game do
  alias __MODULE__
  alias Bs.GameState
  use GenServer

  defmodule Command, do: defstruct [:name, :data]

  @type state :: GameState.t
  @type server :: GenServer.server

  @moduledoc """
  The Game is a GenServer that handles running a single Bs match.
  """

  def start_link(args, opts \\ [])

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def get_game_state(pid) do
    GenServer.call(pid, :get_game_state)
  end

  def get_status(pid) do
    GenServer.call(pid, :get_status)
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  def pause(pid) do
    GenServer.call(pid, :pause)
  end

  def prev(pid) do
    GenServer.call(pid, :prev)
  end

  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  @doc "Replay the current game."
  @spec replay(Game.server) :: term
  def replay(pid) do
    GenServer.call(pid, :replay)
  end

  defdelegate handle_call(request, from, state), to: Game.Server
  defdelegate handle_cast(request, state), to: Game.Server
  defdelegate handle_info(request, state), to: Game.Server
  defdelegate init(args), to: Game.Server

  def find!({:ok, pid}), do: pid
  def find!({:error, {:already_started, pid}}), do: pid
  def find!({:error, e}), do: raise(e)
  def find!(name), do: name |> find |> find!

  defdelegate find(name), to: Game.Registry, as: :lookup_or_create
  defdelegate name(id), to: Game.Registry, as: :via

  defdelegate subscribe(name), to: Game.PubSub
end
