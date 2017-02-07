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

  def start_link(state, opts \\ [])

  def start_link(%State{} = state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  defdelegate get_state(pid), to: GameServer.Client
  defdelegate get_status(pid), to: GameServer.Client
  defdelegate next(pid), to: GameServer.Client
  defdelegate on_change(pid), to: GameServer.Client
  defdelegate on_done(pid), to: GameServer.Client
  defdelegate on_start(pid), to: GameServer.Client
  defdelegate pause(pid), to: GameServer.Client
  defdelegate prev(pid), to: GameServer.Client
  defdelegate resume(pid), to: GameServer.Client
  defdelegate replay(pid), to: GameServer.Client

  defdelegate handle_call(request, from, state), to: GameServer.Server
  defdelegate handle_cast(request, state), to: GameServer.Server
  defdelegate handle_info(request, state), to: GameServer.Server
  defdelegate init(args), to: GameServer.Server
end
