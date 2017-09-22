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

  defdelegate get_game_state(pid), to: Game.Client
  defdelegate get_state(pid), to: Game.Client
  defdelegate get_status(pid), to: Game.Client
  defdelegate next(pid), to: Game.Client
  defdelegate pause(pid), to: Game.Client
  defdelegate prev(pid), to: Game.Client
  defdelegate resume(pid), to: Game.Client
  defdelegate replay(pid), to: Game.Client

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
