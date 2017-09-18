defmodule BattleSnakeWeb.Test.ExampleView do
  use BattleSnakeWeb, :view

  def render("move.json", assigns) do
    turn = assigns["turn"]
    move = Enum.at(~w(up right down left), rem(turn, 4))
    %{move: move}
  end

  def render("start.json", _assigns) do
    %{
      color: "#99c1bc",
      head_type: BattleSnake.SnakeHeads.list() |> Enum.random,
      head_url: "http://battlesnake.stembolt.com/images/division-classic.png",
      name: "BATTLE★SNAKE",
      secondary_color: "6a6676",
      tail_type: BattleSnake.SnakeTails.list() |> Enum.random,
    }
  end
end
