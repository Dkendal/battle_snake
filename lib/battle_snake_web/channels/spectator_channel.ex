defmodule BattleSnakeWeb.SpectatorChannel do
  alias BattleSnake.Replay
  alias BattleSnake.GameServer
  alias BattleSnake.GameStateEvent

  use BattleSnakeWeb, :channel

  @type join_payload :: %{optional(binary) => binary}
  @spec join(binary, join_payload, Phoenix.Socket.t) :: {:ok, Phoenix.Socket} | {:error, any}
  def join("spectator:html:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  def join("spectator:json:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  defp do_join(game_id, payload, socket) do
    if authorized?(payload) do
      {:ok, _pid} = Replay.start_recording(game_id)

      GameServer.PubSub.subscribe(game_id)
      send(self(), :after_join)
      socket = assign(socket, :game_id, game_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  ####################
  # Game State Event #
  ####################

  def handle_info(%GameStateEvent{name: _name, data: state}, socket) do
    content = render_content(content_type(socket), state)
    broadcast(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  ##############
  # After Join #
  ##############

  def handle_info(:after_join, socket) do
    state = socket.assigns.game_id
    |> GameServer.find!
    |> GameServer.get_game_state

    content = render_content(content_type(socket), state)
    push(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  ###################
  # Private Methods #
  ###################

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp render_content("json", state) do
    Poison.encode!(state.world, mode: :consumer)
  end

  defp render_content(_, state) do
    BattleSnakeWeb.SpectatorView
    |> Phoenix.View.render_to_string("board.html", state: state)
    |> String.replace(~r/^\s+|\s+$/m, "")
    |> String.replace(~r/\n+/m, " ")
  end

  defp content_type(socket) do
     [_, type|_] = String.split(socket.topic, ":")
     type
  end
end
