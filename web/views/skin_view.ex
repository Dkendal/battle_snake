defmodule BattleSnake.SkinView do
  alias BattleSnake.GameAdminChannel
  use BattleSnake.Web, :view
  require Logger
  
  def battle_snake_js_object(assigns, acc  \\ %{})

  def battle_snake_js_object(%{game: game} = h, acc) do
    Logger.debug("SkinView.battle_snake_js_object snakes=#{inspect get_in(h, [:game]).snakes}")
    
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
