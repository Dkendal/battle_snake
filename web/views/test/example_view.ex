defmodule BattleSnake.Test.ExampleView do
  use BattleSnake.Web, :view

  def render("move.json", _assigns) do
    %{
      move: "down",
    }
  end

  def render("start.json", _assigns) do
    %{
      name: "BattleSnake Example Snake",
      color: "#ffffff",
      head_url: "http://placecage.com/c/300/300"
    }
  end
end
