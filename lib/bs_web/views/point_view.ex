defmodule BsWeb.PointView do
  use BsWeb, :view

  def render("show.json", %{v: 2, point: point}) do
    %{object: :point, x: point.x, y: point.y}
  end

  def render("show.json", %{v: 1, point: point}) do
    [point.x, point.y]
  end
end
