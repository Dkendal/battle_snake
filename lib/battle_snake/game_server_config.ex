defmodule BattleSnake.GameServerConfig do
  alias BattleSnake.{
    GameServer,
    World,
    GameForm,
    WorldMovement,
    WinConditions,
  }

  @moduledoc """
  Take a game's configuration from the game-form, and returns a new game server
  state for it.
  """

  @doc """
  How to start the game given an id.
  """
  @spec reset(GameForm.t) :: GameForm.t
  def reset(game_form) do
    game_form
    |> GameForm.Reset.reset_game_form()
  end

  def save_history(state) do
    Mnesia.Repo.save state.world
    state
  end

  def setup(game_form, _render_fun) do
    game = reset(game_form)
    world = game.world

    on_start = reduce_f([])

    on_change = reduce_f([
      &save_history/1,
    ])

    on_done = reduce_f([
      &BattleSnake.Rules.last_standing/1,
      &BattleSnake.GameServer.Persistance.save_winner/1,
    ])

    objective =
      WinConditions.game_mode(game_form.game_mode)

    %GameServer.State{
      delay: game_form.delay,
      game_form: game_form,
      game_form_id: game_form.id,
      objective: objective,
      on_change: on_change,
      on_done: on_done,
      on_start: on_start,
      world: world,
    }
  end

  defp reduce_f(funs) do
    fn state ->
      Enum.reduce(funs, state, fn fun, s -> fun.(s) end)
    end
  end
end
