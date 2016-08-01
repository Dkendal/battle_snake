defmodule BattleSnake.Board do
  alias BattleSnake.{Point}

  def height(board) do
    length board
  end

  def width([row | _]) do
    length row
  end

  def empty, do: %{"state" => "empty"}
  def food, do: %{"state" => "food"}
end
