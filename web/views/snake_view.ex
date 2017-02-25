defmodule BattleSnake.SnakeView do
  alias BattleSnake.Death
  use BattleSnake.Web, :view

  def head_image_url(%{url: base, head_url: "/" <> url}) do
    base <> "/" <> url
  end

  def head_image_url(%{head_url: url}) do
    url
  end

  def cause_of_death_text(cause) do
    alias BattleSnake.Death
    case cause do
      %Death.StarvationCause{} ->
        "Starved to death"
      %Death.WallCollisionCause{} ->
        "Crashed into a wall"
      %Death.BodyCollisionCause{with: id} ->
        "Collided with #{id}'s body"
      %Death.HeadCollisionCause{with: id} ->
        "Consumed by #{id}"
      _ ->
        ""
    end
  end
end
