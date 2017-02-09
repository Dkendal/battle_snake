defmodule BattleSnake.GameForm do
  @api Application.get_env(:battle_snake, :snake_api)

  alias __MODULE__
  alias BattleSnake.{
    GameServer,
    GameServer.State,
    Rules,
    Snake,
    SnakeForm,
    WinConditions,
    World,
  }

  use BattleSnake.Web, :model

  @permitted [:height, :width, :delay, :max_food, :game_mode]
  @singleplayer "singleplayer"
  @multiplayer "multiplayer"
  @game_modes [@singleplayer, @multiplayer]
  @required [:delay,
             :game_mode,
             :height,
             :max_food,
             :width]

  defmacro game_modes, do: @game_modes
  defmacro multiplayer, do: @multiplayer
  defmacro singleplayer, do: @singleplayer

  @type t :: %GameForm{
    snakes: [SnakeForm],
    world: World,
    width: pos_integer,
    height: pos_integer,
    delay: non_neg_integer,
    max_food: non_neg_integer,
    winners: [Snake.t],
    game_mode: string
  }

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
    |> validate_required(@required)
    |> set_id()
    |> remove_empty_snakes()
  end

  def remove_empty_snakes(changeset) do
    changeset
    |> update_change(:snakes, &reject_deleted_snakes/1)
  end

  def reject_deleted_snakes(changeset) do
    delete = fn changeset ->
      get_field(changeset, :delete) == "" ||
        get_field(changeset, :url) in ["", nil]
    end

    Enum.reject(changeset, delete)
  end

  def set_id(changeset) do
    set_id(changeset, get_field(changeset, :id))
  end

  def set_id(changeset, nil) do
    id = Ecto.UUID.generate()
    put_change(changeset, :id, id)
  end

  def set_id(changeset, _id), do: changeset

  @spec reload_game_server_state(t) :: State.t
  def reload_game_server_state(%GameForm{} = game_form) do
    game_form
    |> GameForm.Reset.reset_game_form
    |> to_game_server_state
  end

  @spec to_game_server_state(t) :: State.t
  def to_game_server_state(%GameForm{} = game_form) do
    delay = game_form.delay
    game_form_id = game_form.id
    world = game_form.world

    fun_apply = fn (funs, state) ->
      Enum.reduce(funs, state, fn fun, s -> fun.(s) end)
    end

    save = fn state ->
      Mnesia.Repo.save(state.world)
      state
    end

    on_change = &fun_apply.([save], &1)

    on_done = fn state ->
      fun_apply.(
        [&Rules.last_standing/1,
         &GameServer.Persistance.save_winner/1],
        state)
    end

    objective = WinConditions.game_mode(game_form.game_mode)

    %State{
      delay: delay,
      game_form: game_form,
      game_form_id: game_form_id,
      objective: objective,
      on_change: on_change,
      on_done: on_done,
      world: world,
    }
  end
end

defimpl Poison.Encoder, for: BattleSnake.GameForm do
  def encode(game_form, opts) do
    %{game_id: game_form.id,
      height: game_form.height,
      width: game_form.width}
    |> Poison.encode!(opts)
  end
end
