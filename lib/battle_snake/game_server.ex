defmodule BattleSnake.GameServer do
  alias __MODULE__
  alias __MODULE__.State
  use GenServer

  defmodule Command, do: defstruct [:name, :data]

  @type state :: State.t
  @type server :: GenServer.server

  @moduledoc """
  The GameServer is a GenServer that handles running a single BattleSnake match.
  """

  def start_link(args, opts \\ [])

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  defdelegate get_game_state(pid), to: GameServer.Client
  defdelegate get_state(pid), to: GameServer.Client
  defdelegate get_status(pid), to: GameServer.Client
  defdelegate next(pid), to: GameServer.Client
  defdelegate pause(pid), to: GameServer.Client
  defdelegate prev(pid), to: GameServer.Client
  defdelegate resume(pid), to: GameServer.Client
  defdelegate replay(pid), to: GameServer.Client

  defdelegate handle_call(request, from, state), to: GameServer.Server
  defdelegate handle_cast(request, state), to: GameServer.Server
  defdelegate handle_info(request, state), to: GameServer.Server
  defdelegate init(args), to: GameServer.Server

  def find!({:ok, pid}), do: pid
  def find!({:error, {:already_started, pid}}), do: pid
  def find!({:error, e}), do: raise(e)
  def find!(name), do: name |> find |> find!

  defdelegate find(name), to: GameServer.Registry, as: :lookup_or_create

  defdelegate subscribe(name), to: GameServer.PubSub
end
