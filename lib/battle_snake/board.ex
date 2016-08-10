defmodule BattleSnake.Board do
  def empty, do: %{"state" => "empty"}
  def food, do: %{"state" => "food"}
end
