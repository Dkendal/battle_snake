defmodule BsWeb.GameChannel do
  alias Bs.Event
  alias Bs.Game
  alias Phoenix.View

  use BsWeb, :channel

  def join("game:" <> id, _params, socket) do
    :ok = Game.subscribe(id)

    send(self(), :after_join)

    socket = assign(socket, :id, id)

    {:ok, socket}
  end

  def handle_in(cmd, _params, socket) do
    id = socket.assigns.id

    case cmd do
      "stop" ->
        Game.restart(id)
        {:reply, :ok, socket}

      "next" ->
        Game.next(id)
        {:reply, :ok, socket}

      "prev" ->
        Game.prev(id)
        {:reply, :ok, socket}

      "resume" ->
        Game.resume(id)
        {:reply, :ok, socket}

      "pause" ->
        Game.pause(id)
        {:reply, :ok, socket}

      _action ->
        {:reply, :error, socket}
    end
  end

  def handle_info(message, socket) do
    id = socket.assigns.id

    case message do
      {:tick, state} ->
        broadcast(socket, "tick", %{content: render(state)})
        {:noreply, socket}

      %Event{name: name} ->
        broadcast(socket, name, message)
        {:noreply, socket}

      :after_join ->
        state = Game.get_game_state(id)
        push(socket, "tick", %{content: render(state)})
        {:noreply, socket}
    end
  end

  defp render(state) do
    View.render(BsWeb.GameStateView, "show.json", game_state: state)
  end
end
