defmodule BattleSnake.GameForm do
  @api Application.get_env(:battle_snake, :snake_api)

  alias BattleSnake.SnakeForm
  alias BattleSnake.{World, Snake}

  use BattleSnake.Web, :model

  @permitted [:height, :width, :delay, :max_food, :game_mode]
  @singleplayer "singleplayer"
  @multiplayer "multiplayer"
  @game_modes [@singleplayer, @multiplayer]

  defmacro game_modes, do: @game_modes
  defmacro multiplayer, do: @multiplayer
  defmacro singleplayer, do: @singleplayer

  schema "game" do
    embeds_many :snakes, SnakeForm
    embeds_one :world, World
    field :width, :integer, default: 20
    field :height, :integer, default: 20
    field :delay, :integer, default: 300
    field :max_food, :integer, default: 1
    field :winners, {:array, :string}, default: []
    field :game_mode, :string, default: @multiplayer
  end

  def changeset(game, params \\ %{}) do
    game
    |> cast(params, @permitted)
    |> cast_embed(:world)
    |> cast_embed(:snakes)
    |> validate_inclusion(:game_mode, @game_modes)
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

defimpl Poison.Encoder, for: BattleSnake.GameForm do
  def encode(game_form, opts) do
    %{game_id: game_form.id,
      height: game_form.height,
      width: game_form.width}
    |> Poison.encode!(opts)
  end
end
