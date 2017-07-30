defmodule BattleSnake.WinConditions do
  require BattleSnakeWeb.GameForm

  @spec game_mode(binary) :: (BattleSnake.World.t -> boolean)
  def game_mode(game_mode) do
    case game_mode do
      BattleSnakeWeb.GameForm.singleplayer() ->
        &singleplayer/1
      BattleSnakeWeb.GameForm.multiplayer() ->
        &multiplayer/1
    end
  end

  def singleplayer(world) do
    length(world.snakes) <= 0
  end

  def multiplayer(world) do
    length(world.snakes) <= 1
  end
end
