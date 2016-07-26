defmodule BattleSnakeServer.Game do
  use BattleSnakeServer.Web, :model

  @fields [:id, :state]

  defstruct @fields

  def fields, do: @fields
  def table, do: [attributes: @fields]

  def record(game) do
    get = &Map.get(game, &1)
    attrs = Enum.map(fields, get)
    List.to_tuple [__MODULE__ |attrs]
  end
end
