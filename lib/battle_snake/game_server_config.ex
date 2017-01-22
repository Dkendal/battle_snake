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
  def reset(game_form) do
    # {:ok, game_form} = GameForm.get(id)
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

    %GameServer.State{
      world: world,
      reducer: &reducer/1,
      opts: opts,
      on_change: on_change,
    }
  end
end
