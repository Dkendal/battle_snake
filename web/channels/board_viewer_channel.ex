defmodule BattleSnake.BoardViewerChannel do
  alias BattleSnake.GameServer

  use BattleSnake.Web, :channel

  @typedoc """
  Optional values:
      "contentType" => "html" | "json"
  """
  @type join_payload :: %{optional(binary) => binary}
  @spec join(binary, join_payload, Phoenix.Socket.t) :: {:ok, Phoenix.Socket} | {:error, any}
  def join("board_viewer:" <> game_id, payload, socket) do
    if authorized?(payload) do
      GameServer.PubSub.subscribe(game_id)
      send(self(), :after_join)
      socket = set_content_type(socket, payload)
      socket = assign(socket, :game_id, game_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(%GameServer.State.Event{name: _name, data: state}, socket) do
    content = render_content(socket.assigns.content_type, state)
    broadcast(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    state = socket.assigns.game_id
    |> GameServer.find!
    |> GameServer.get_game_state

    content = render_content(socket.assigns.content_type, state)
    push(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp render_content(:json, state) do
    Poison.encode!(state.world, consumer: true)
  end

  defp render_content(_, state) do
    BattleSnake.BoardViewerView
    |> Phoenix.View.render_to_string("board.html", state: state)
    |> String.replace(~r/^\s+|\s+$/m, "")
    |> String.replace(~r/\n+/m, " ")
  end

  defp set_content_type(socket, payload) do
    content_type =
      case payload["contentType"] do
        "html" -> :html
        "json" -> :json
        _ -> :html
      end
    assign socket, :content_type, content_type
  end
end
