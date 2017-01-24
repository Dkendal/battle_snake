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

  def setup(game_form, on_change) do
    game = reset(game_form)
    world = game.world

    opts = [
      delay: game.delay,
      objective: &BattleSnake.WinConditions.single_player/1
    ]

    on_done = fn state ->
      [&BattleSnake.Rules.last_standing/1,
       &BattleSnake.GameServer.Persistance.save_winner/1]
      |> Enum.reduce(state, fn fun, s -> fun.(s) end)
    end

    %GameServer.State{
      game_form: game_form,
      world: world,
      reducer: &reducer/1,
      opts: opts,
      on_change: on_change,
      on_done: on_done,
    }
  end
end
