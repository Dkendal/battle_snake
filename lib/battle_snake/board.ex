defmodule BattleSnake.Board do
  def new(width, height) do
    for _ <- 1..width do
      for _ <- 1..height do
        empty
      end
    end
  end

  def height(board) do
    length board
  end

  def width([row | _]) do
    length row
  end

  def empty, do: %{"state" => "empty"}
  def food, do: %{"state" => "food"}
end
