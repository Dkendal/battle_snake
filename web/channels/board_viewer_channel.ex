defmodule BattleSnake.BoardViewerChannel do
  alias BattleSnake.GameServer

  use BattleSnake.Web, :channel

  def join("board_viewer:" <> game_id, payload, socket) do
    if authorized?(payload) do
      GameServer.PubSub.subscribe(game_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(%GameServer.State.Event{name: name, data: state}, socket) do
    html = Phoenix.View.render_to_string(BattleSnake.PlayView, "board.html", state: state)
    broadcast(socket, "tick", %{html: html})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
