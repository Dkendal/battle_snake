defmodule BattleSnakeWeb.Test.ExampleView do
  use BattleSnakeWeb, :view

  def render("move.json", assigns) do
    turn = assigns["turn"]
    move = Enum.at(~w(up right down left), rem(turn, 4))
    %{move: move}
  end

  def render("start.json", _assigns) do
    %{
      name: "BATTLE★SNAKE",
      color: "#99c1bc",
      secondary_color: "6a6676",
      head_type: "dead",
      head_type: BattleSnake.SnakeHeads.list() |> Enum.random,
      tail_type: BattleSnake.SnakeTails.list() |> Enum.random,
      head_url: "http://battlesnake.stembolt.com/images/division-classic.png"
    }
  end
end
