defmodule BattleSnake.ReplayChannel do
  alias BattleSnake.Replay.PlayBack.Frame
  use BattleSnake.Web, :channel

  def join("replay:html:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  def join("replay:json:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  defp do_join(game_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(%Frame{data: state}, socket) do
    content = render_content(content_type(socket), state)
    broadcast(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end

  defp render_content("json", state) do
    Poison.encode!(state.world, mode: :consumer)
  end

  defp render_content(_, state) do
    BattleSnake.SpectatorView
    |> Phoenix.View.render_to_string("board.html", state: state)
    |> String.replace(~r/^\s+|\s+$/m, "")
    |> String.replace(~r/\n+/m, " ")
  end

  defp content_type(socket) do
    [_, type|_] = String.split(socket.topic, ":")
    type
  end
end
