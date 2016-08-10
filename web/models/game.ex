defmodule BattleSnakeServer.Game do
  @api Application.get_env(:battle_snake_server, :snake_api)

  alias BattleSnakeServer.Snake, as: Form
  alias BattleSnake.{World, Snake}

  use BattleSnakeServer.Web, :model

  @permitted [:height, :width, :delay, :max_food]

  schema "game" do
    embeds_many :snakes, Form
    embeds_one :world, World
    field :width, :integer, default: 20
    field :height, :integer, default: 20
    field :delay, :integer, default: 300
    field :max_food, :integer, default: 1
  end

  def reset_snake(%World{} = world, %Snake{} = snake) do
    coords = new_coords(world)
    %{snake| coords: coords}
  end

  def new_coords(%World{} = world) do
    point = World.rand_unoccupied_space(world)
    coords = List.duplicate(point, 3)
  end

  def load_snake_form_fn() do
    fn form, game ->
      snake = @api.load(form, game)
      snake = reset_snake(game.world, snake)
      snake = %{snake| url: form.url}
      update_in(game.world.snakes, &[snake|&1])
    end
  end

  def reset_world(game) do
    world = %World{
      height: game.height,
      max_food: game.max_food,
      snakes: [],
      width: game.width,
    }

    game = put_in game.world, world

    snakes = game.snakes

    game = Enum.reduce(snakes, game, load_snake_form_fn)

    world = World.stock_food(game.world)

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
    id = to_string DateTime.to_unix(DateTime.utc_now)
    put_change(changeset, :id, id)
  end

  def set_id(changeset, _id), do: changeset
end
