defmodule BattleSnake.WinConditions do
  def single_player(world) do
    length(world.snakes) <= 0
  end

  def death_match(world) do
    length(world.snakes) <= 1
  end
end
