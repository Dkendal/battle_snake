defmodule BattleSnakeWeb.SpectatorChannel do
  alias BattleSnake.Game
  alias BattleSnake.GameStateEvent

  use BattleSnakeWeb, :channel

  @type join_payload :: %{optional(binary) => binary}
  @spec join(binary, join_payload, Phoenix.Socket.t) :: {:ok, Phoenix.Socket} | {:error, any}
  def join("spectator:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  defp do_join(game_id, payload, socket) do
    if authorized?(payload) do
      Game.PubSub.subscribe(game_id)
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
    broadcast(socket, "tick", %{content: render(state.world)})

    {:noreply, socket}
  end

  ##############
  # After Join #
  ##############

  def handle_info(:after_join, socket) do
    state = socket.assigns.game_id
    |> Game.find!
    |> Game.get_game_state

    push(socket, "tick", %{content: render(state.world)})

    {:noreply, socket}
  end

  ###################
  # Private Methods #
  ###################

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp render(board) do
    Phoenix.View.render(
      BattleSnakeWeb.BoardView,
      "show.json",
      board: board
    )
  end
end
