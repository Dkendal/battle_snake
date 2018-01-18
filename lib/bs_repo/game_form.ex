defmodule BsRepo.GameForm do
  alias BsWeb.SnakeForm

  use BsWeb, :model
  use Ecto.Schema

  @singleplayer "singleplayer"
  @multiplayer "multiplayer"
  @game_modes [@singleplayer, @multiplayer]

  defmacro game_modes, do: @game_modes

  schema "Elixir.BsRepo.GameForm" do
    embeds_many(:snakes, SnakeForm)
    field(:world, :any, virtual: true)
    field(:width, :integer, default: 20)
    field(:height, :integer, default: 20)
    field(:delay, :integer, default: 300)
    field(:max_food, :integer, default: 1)
    field(:snake_start_length, :integer, default: 3)
    field(:game_mode, :string, default: @multiplayer)
    field(:recv_timeout, :integer, default: 200)
  end

  @required  [:delay, :game_mode, :height, :max_food, :snake_start_length, :recv_timeout, :width]
  @permitted [:delay, :game_mode, :height, :max_food, :snake_start_length, :recv_timeout, :width]
  def changeset(game, params \\ %{}) do
    game
    |> cast(params, @permitted)
    |> cast_embed(:snakes)
    |> validate_inclusion(:game_mode, @game_modes)
    |> validate_number(:recv_timeout, greater_than_or_equal_to: 0)
    |> validate_number(:delay, greater_than_or_equal_to: 0)
    |> validate_required(@required)
    |> remove_empty_snakes()
  end

  def remove_empty_snakes(changeset) do
    changeset
    |> update_change(:snakes, &reject_deleted_snakes/1)
  end

  def reject_deleted_snakes(changeset) do
    delete = fn changeset ->
      get_field(changeset, :delete) == true || get_field(changeset, :url) == nil
    end

    Enum.reject(changeset, delete)
  end
end

defimpl Poison.Encoder, for: BsRepo.GameForm do
  def encode(game_form, opts) do
    %{game_id: game_form.id, height: game_form.height, width: game_form.width}
    |> Poison.encode!(opts)
  end
end
