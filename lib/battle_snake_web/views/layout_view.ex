defmodule BattleSnakeWeb.LayoutView do
  alias BattleSnakeWeb.GameAdminChannel

  use BattleSnakeWeb, :view

  def battle_snake_js_object(assigns, acc  \\ %{})

  def battle_snake_js_object(%{is_replay: is_replay} = h, acc) do
    h
    |> Map.delete(:is_replay)
    |> battle_snake_js_object(put_in(acc[:isReplay], is_replay))
  end

  def battle_snake_js_object(%{game: game} = h, acc) do
    h
    |> Map.delete(:game)
    |> battle_snake_js_object(put_in(acc[:gameId], game.id))
  end

  def battle_snake_js_object(_, acc) do
    s = GameAdminChannel.available_requests()
    put_in(acc[:gameAdminAvailableRequests], s)
    |> Poison.encode!
  end
end
