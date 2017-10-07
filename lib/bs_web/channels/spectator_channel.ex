defmodule BsWeb.SpectatorChannel do
  alias Bs.Event
  alias Bs.Game
  alias BsWeb.BoardView
  alias Phoenix.View

  use BsWeb, :channel

  def join("spectator", %{"id" => id}, socket) do
    :ok = Game.subscribe(id)

    send(self(), :after_join)

    socket = assign(socket, :id, id)

    {:ok, socket}
  end

  ####################
  # Game State Event #
  ####################

  def handle_info({:tick, state}, socket) do
    broadcast(socket, "tick", %{content: render(state.world)})

    {:noreply, socket}
  end

  def handle_info(%Event{} = event, socket) do
    broadcast socket, "event", event
    {:noreply, socket}
  end

  ##############
  # After Join #
  ##############

  def handle_info(:after_join, socket) do
    state = Game.get_game_state socket.assigns.id

    push(socket, "tick", %{content: render(state.world)})

    {:noreply, socket}
  end

  ###################
  # Private Methods #
  ###################

  defp render(board) do
    View.render(
      BoardView,
      "show.json",
      board: board
    )
  end
end
