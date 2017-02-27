defmodule BattleSnake.Test.ExampleView do
  use BattleSnake.Web, :view

  def render("move.json", assigns) do
    turn = assigns["turn"]
    move = Enum.at(~w(up right down left), rem(turn, 4))
    %{move: move}
  end

  def render("start.json", _assigns) do
    %{
      name: "BattleSnake Example Snake",
      color: "#ffffff",
      head_url: "http://placecage.com/c/300/300"
    }
  end
end
