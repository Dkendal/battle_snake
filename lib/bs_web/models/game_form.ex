defmodule BsWeb.GameForm do
  alias Bs.GameForm.Reset
  alias Bs.GameState
  alias BsWeb.SnakeForm
  alias __MODULE__

  use BsWeb, :model
  use Ecto.Schema

  @singleplayer "singleplayer"
  @multiplayer "multiplayer"
  @game_modes [@singleplayer, @multiplayer]

  defmacro game_modes, do: @game_modes

  schema "Elixir.BsWeb.GameForm" do
    embeds_many :snakes, SnakeForm
    field :world, :any, virtual: true
    field :width, :integer, default: 20
    field :height, :integer, default: 20
    field :delay, :integer, default: 300
    field :max_food, :integer, default: 1
    field :game_mode, :string, default: @multiplayer
    field :recv_timeout, :integer, default: 200
  end

  @required [
    :delay,
    :game_mode,
    :height,
    :max_food,
    :recv_timeout,
    :width,
  ]
  @permitted [
    :delay,
    :game_mode,
    :height,
    :max_food,
    :recv_timeout,
    :width,
  ]
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
      get_field(changeset, :delete) == true ||
        get_field(changeset, :url) == nil
    end

    Enum.reject(changeset, delete)
  end

  def reload_game_server_state(%GameForm{} = game_form) do
    game_form
    |> Reset.reset_game_form
    |> to_game_server_state
  end

  def to_game_server_state(%GameForm{} = game_form) do
    delay = game_form.delay
    game_form_id = game_form.id
    world = game_form.world

    singleplayer = fn (world) ->
      length(world.snakes) <= 0
    end

    multiplayer = fn (world) ->
      length(world.snakes) <= 1
    end

    objective = case game_form.game_mode do
      @singleplayer -> singleplayer
      @multiplayer -> multiplayer
    end

    %GameState{
      delay: delay,
      game_form: game_form,
      game_form_id: game_form_id,
      objective: objective,
      world: world,
    }
  end
end

defimpl Poison.Encoder, for: BsWeb.GameForm do
  def encode(game_form, opts) do
    %{game_id: game_form.id,
      height: game_form.height,
      width: game_form.width}
    |> Poison.encode!(opts)
  end
end
