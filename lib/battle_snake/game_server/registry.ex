defmodule BattleSnake.GameServer.Registry do
  alias BattleSnake.GameServer
  @name __MODULE__

  @type name :: binary | atom
  @spec via(name) :: GenServer.name
  def via(value) do
    {:via, Registry, {@name, value}}
  end

  @spec create(name, GameServer.state) :: GenServer.on_start
  def create(value, %GameServer.State{} = state) do
    GameServer.Supervisor.start_game_server([state, [name: via(value)]])
  end

  @spec lookup(name) :: [{pid, Registry.value}]
  def lookup(value) do
    Registry.lookup(@name, value)
  end

  @doc """
  Return {:ok, pid} for the already registered game server, or start a new
  instance and register it.
  """
  @spec create(name, GameServer.state) :: GenServer.on_start
  def lookup_or_create(value, state) do
    case lookup(value) do
      [{pid, _}] ->
        {:ok , pid}
      [] ->
        create(value, state)
    end
  end
end
