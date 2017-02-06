defmodule BattleSnake.GameAdminChannel do
  use BattleSnake.Web, :channel

  def join("game_admin:" <> game_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
