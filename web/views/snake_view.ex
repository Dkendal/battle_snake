defmodule BattleSnake.SnakeView do
  use BattleSnake.Web, :view

  def head_image_url(%{url: base, head_url: "/" <> url}) do
    base <> "/" <> url
  end

  def head_image_url(%{head_url: url}) do
    url
  end
end
