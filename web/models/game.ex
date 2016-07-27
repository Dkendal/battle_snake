defmodule BattleSnakeServer.Game do
  alias BattleSnakeServer.{Snake}
  alias Snake.{World}

  use BattleSnakeServer.Web, :model

  @permitted [:height, :width]

  schema "game" do
    field :height, :integer
    embeds_many :snakes, Snake
    embeds_one :state, World
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
    |> cast_embed(:state)
    |> cast_embed(:snakes)
    |> remove_empty_snakes()
  end

  def remove_empty_snakes(changeset) do
    changeset
    |> update_change(:snakes, &reject_deleted_snakes/1)
  end

  def reject_deleted_snakes(changeset) do
    delete = fn changeset ->
      get_field(changeset, :delete) || get_field(changeset, :url) == ""
    end

    Enum.reject(changeset, delete)
  end
end
