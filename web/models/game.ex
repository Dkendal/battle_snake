defmodule BattleSnakeServer.Game do
  alias BattleSnakeServer.{Snake}
  alias BattleSnake.{World}

  use BattleSnakeServer.Web, :model

  @permitted [:height, :width]

  schema "game" do
    embeds_many :snakes, Snake
    embeds_one :world, World
    field :width, :integer, default: 20
    field :height, :integer, default: 20
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


  def all do
    fn ->
      :qlc.e(:mnesia.table __MODULE__)
    end
    |> :mnesia.async_dirty()
    |> Enum.map(&load/1)
  end

  def last do
    load :mnesia.last(__MODULE__)
  end

  def get(id) do
    read = fn ->
      :mnesia.read __MODULE__, id
    end

    {:atomic, [game]} = :mnesia.transaction read

    load(game)
  end

  def reset_world(game) do
    world = %World{
      width: game.width,
      height: game.height,
    }

    world = World.stock_food(world)

    put_in game.world, world
  end

  def save(game) do
    write = fn ->
      :mnesia.write(record(game))
    end

    {:atomic, :ok} = :mnesia.transaction write

    game
  end

  def changeset(game, params \\ %{}) do
    game
    |> cast(params, @permitted)
    |> cast_embed(:world)
    |> cast_embed(:snakes)
    |> set_id()
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

  def set_id(changeset) do
    set_id(changeset, get_field(changeset, :id))
  end

  def set_id(changeset, nil) do
    id = Enum.join(Tuple.to_list(:erlang.now), "-")
    put_change(changeset, :id, id)
  end

  def set_id(changeset, _id), do: changeset
end
