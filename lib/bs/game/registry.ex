defmodule Bs.Game.Registry do
  alias Registry, as: R

  @k __MODULE__

  def lookup(id), do: R.lookup(@k, id)
  def register(key, value), do: R.register(@k, key, value)
  def dispatch(id, fun), do: R.dispatch(@k, id, fun)

  def find(id) do
    case R.lookup(@k, id) do
      [{pid, _}] ->
        {:ok, pid}

      _ ->
        :error
    end
  end
end
