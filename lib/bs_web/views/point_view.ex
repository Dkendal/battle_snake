defmodule BsWeb.PointView do
  use BsWeb, :view

  def render("show.json", %{point: point}) do
    [point.x, point.y]
  end
end
