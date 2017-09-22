defmodule Bs.Game.Registry do
  alias Bs.Game
  alias Bs.GameState
  alias BsWeb.GameForm
  @name __MODULE__

  @type name :: binary | atom
  @type initializer :: name | GameState.t | GameForm.t

  @spec via(name) :: GenServer.name
  def via(id), do: {:via, Registry, {@name, id}}

  @spec options(name) :: GenServer.options
  def options(id), do: [name: via(id)]

  @spec create(name) :: {:ok, pid} | :error
  def create(id) when is_binary(id) do
    create(id, id)
  end

  @spec create(initializer, name) :: {:ok, pid} | :error
  def create(state, id) when is_binary(id) do
    Game.Supervisor.start_game_server([state, options(id)])
  end

  def create(_state, id) do
    raise """
    Expected id to a be a binary. id: #{inspect id}
    """
  end

  @spec lookup(name) :: [{pid, Registry.value}]
  def lookup(id) do
    Registry.lookup(@name, id)
  end

  @spec lookup(name) :: {:ok, pid} | :error
  def find(id) do
    with [{pid, _}] <- Registry.lookup(@name, id) do
      {:ok, pid}
    else
      [] ->
        :error
    end
  end

  @spec lookup_or_create(name) :: {:ok, pid} | :error
  def lookup_or_create(id) when is_binary(id) do
    lookup_or_create(id, id)
  end

  @spec lookup_or_create(initializer, name) :: {:ok, pid} | :error
  def lookup_or_create(state, id) when is_binary(id) do
    case lookup(id) do
      [{pid, _}] -> {:ok , pid}
      [] -> create(state, id)
    end
  end
end
