defmodule BattleSnake.GameServerConfig do
  alias BattleSnake.{
    GameServer,
    World,
    GameForm,
    WorldMovement,
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

  @doc """
  What the game should do each turn.
  """
  def reducer(world) do
    world
    |> World.inc_turn()
    |> WorldMovement.next()
    |> World.step()
    |> World.stock_food()
  end

  def save_history(state) do
    # BattleSnake.World.save state.world
    state
  end

  def setup(game_form, render_fun) do
    game = reset(game_form)
    world = game.world

    objective_fun =
      BattleSnake.WinConditions.game_mode(game_form.game_mode)

    opts = [
      delay: game.delay,
      objective: objective_fun
    ]

    on_start = reduce_f([
      render_fun,
    ])

    on_change = reduce_f([
      &save_history/1,
      render_fun,
    ])

    on_done = reduce_f([
      &BattleSnake.Rules.last_standing/1,
      &BattleSnake.GameServer.Persistance.save_winner/1,
      render_fun,
    ])

    %GameServer.State{
      game_form: game_form,
      world: world,
      reducer: &reducer/1,
      opts: opts,
      on_change: on_change,
      on_start: on_start,
      on_done: on_done,
    }
  end

  defp reduce_f(funs) do
    fn state ->
      Enum.reduce(funs, state, fn fun, s -> fun.(s) end)
    end
  end
end
