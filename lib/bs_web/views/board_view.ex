defmodule BsWeb.BoardView do
  use BsWeb, :view

  def render("show.json", %{board: record}) do
    snakes =
      (record.snakes ++ record.dead_snakes) |> Enum.sort_by(& &1.id)
      |> Enum.map(&snake_view/1)

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

  defp snake_view(record) do
    %{
      color: record.color,
      coords: record.coords,
      headType: record.head_type,
      headUrl: record.head_url,
      health: record.health_points,
      id: record.id,
      name: record.name,
      status: record.status,
      tailType: record.tail_type,
      taunt: record.taunt
    }
  end
end
