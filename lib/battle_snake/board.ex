defmodule BattleSnake.Board do
  alias BattleSnake.{Row}

  use Ecto.Schema

  schema "world" do
    embeds_many :rows, Row
    # embeds_many :dead_snakes, Snake
    # field :food
    # field :height
    # field :id
    # field :snakes
    # field :turn
    # field :width
  end


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
