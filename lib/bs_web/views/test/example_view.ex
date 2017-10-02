defmodule BsWeb.Test.ExampleView do
  use BsWeb, :view

  @heads Bs.Const.heads
  @tails Bs.Const.tails

  def render("move.json", assigns) do
    turn = assigns["turn"]
    move = Enum.at(~w(up right down left), rem(turn, 4))
    %{move: move}
  end

  def render("start.json", _assigns) do
    %{
      color: "#99c1bc",
      head_type: @heads |> Enum.random,
      head_url: "/images/division-classic.svg",
      name: "BATTLE★SNAKE",
      secondary_color: "6a6676",
      tail_type: @tails |> Enum.random,
    }
  end
end
