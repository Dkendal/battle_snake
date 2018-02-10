defmodule BsWeb.Board.BoardView do
  use BsWeb, :view

  def render("show.json", %{board: record}) do
    snakes =
      (record.snakes ++ record.dead_snakes)
      |> Enum.sort_by(& &1.id)
      |> Enum.map(&render_one(&1, BsWeb.Board.SnakeView, "show.json"))

    %{
      id: record.id,
      food: record.food,
      gameId: record.game_id,
      height: record.height,
      snakes: snakes,
      turn: record.turn,
      width: record.width
    }
  end
end
