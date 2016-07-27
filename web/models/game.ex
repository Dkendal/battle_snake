defmodule BattleSnakeServer.Game do
  use Ecto.Schema
  use BattleSnakeServer.Web, :model
  import Ecto.Changeset

  @permitted [:height, :snakes, :state, :width]

  schema "game" do
    field :height, :integer
    field :snakes, {:array, :map}
    field :state, :map
    field :width, :integer
  end

  def fields, do: __schema__(:fields)

  def table, do: [attributes: fields]

  def record(game) do
    get = &Map.get(game, &1)
    attrs = Enum.map(fields, get)
    List.to_tuple [__MODULE__ |attrs]
  end

  def load(record) do
    [__MODULE__ |attrs] = Tuple.to_list(record)
    attrs = Enum.zip(fields, attrs)
    struct(__MODULE__, attrs)
  end

  def changeset(game, params \\ %{}) do
    game
    |> cast(params, @permitted)
  end
end
