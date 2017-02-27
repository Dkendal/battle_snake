defmodule BattleSnake.BoardViewerView do
  alias BattleSnake.Point
  alias BattleSnake.SnakeView
  use BattleSnake.Web, :view
  use BattleSnake.Point

  @food_r 0.25

  def food_obj(point) do
    content_tag(:circle, "",
      cy: point.y + 0.5,
      cx: point.x + 0.5,
      r: @food_r,
      class: "obj-food")
  end
end
