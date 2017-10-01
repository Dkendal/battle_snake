defmodule Bs.Game.Registry do
  alias Bs.Game.Supervisor
  alias Bs.GameState
  alias BsWeb.GameForm

  @name __MODULE__

  @type key :: Registry.key
  @type value :: Registry.value
  @type initializer :: key | GameState.t | GameForm.t

  def via(id), do: {:via, Registry, {@name, id}}

  def options(id), do: [name: via(id)]

  def create(id) when is_binary(id) do
    create(id, id)
  end

  def create(state, id)
  when is_binary(id)
  and is_map(state)
  do
    Supervisor.start_game_server([state, options(id)])
  end

  def create(fun, id) when is_function(fun) do
    create(fun.(), id)
  end

  def create(_state, id) do
    raise """
    Expected id to a be a binary. id: #{inspect id}
    """
  end

  def lookup(id) do
    Registry.lookup(@name, id)
  end

  def find(id) do
    case Registry.lookup(@name, id) do
      [{pid, _}] ->
        {:ok, pid}
      _ ->
        :error
    end
  end

  def lookup_or_create(fun, id)
  when is_binary(id)
  and is_function(fun)
  do
    case lookup(id) do
      [{pid, _}] ->
        {:ok , pid}
      _ ->
        create(fun, id)
    end
  end
end
