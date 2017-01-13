defmodule Types do
  import Property
  require Property
  import :proper
  import :proper_types

  def point(world) do
    h = suchthat pos_integer(), & &1 < world.height
    w = suchthat pos_integer(), & &1 < world.width

    let {w, h}, fn {x, y} ->
      %BattleSnake.Point{x: x, y: y}
    end
  end

  @doc """
  Generate a snake that occupies at least one tile on the world.
  """
  def snake(world) do
    coords = suchthat(list(point(world)), & length(&1) > 0)

    let coords, fn coords ->
      %BattleSnake.Snake{
        coords: coords
      }
    end
  end

  def world() do
    let {pos_integer(), pos_integer(), pos_integer()}, fn {h, w, z} ->
      ws = %BattleSnake.World{height: h, width: w, max_food: z}

      let list(snake(ws)), fn s ->
        %{ws| snakes: s}
      end
    end
  end
end
