defmodule BattleSnake.WinConditions do
  require BattleSnake.GameForm

  @spec game_mode(binary) :: (BattleSnake.World.t -> boolean)
  def game_mode(game_mode) do
    case game_mode do
      BattleSnake.GameForm.singleplayer() ->
        &single_player/1
      BattleSnake.GameForm.multiplayer() ->
        &death_match/1
    end
  end

  def single_player(world) do
    length(world.snakes) <= 0
  end

  def death_match(world) do
    length(world.snakes) <= 1
  end
end
