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
    {:ok, pid} =
      socket
      |> get_id
      |> Game.find_or_start()

    case cmd do
      "resume" ->
        Game.resume(pid)

      "next" ->
        Game.next(pid)

      "prev" ->
        Game.prev(pid)

      "pause" ->
        Game.pause(pid)

      "stop" ->
        # FIXME rename command to reset
        Game.reset(pid)
    end

    {:noreply, socket}
  end

  def handle_info(message, socket) do
    case message do
      {:tick, state} ->
        data = render(state)
        broadcast(socket, "tick", data)

      %Event{name: name} ->
        # FIXME deprecated
        # Reset events are no longer processed on the front end so this
        # should be removed.
        broadcast(socket, name, message)

      :after_join ->
        data =
          socket
          |> get_id
          |> Game.find_or_start!()
          |> Game.get_game_state()
          |> render

        push(socket, "tick", data)
    end

    {:noreply, socket}
  end

  defp get_id(socket) do
    socket.assigns.id
  end

  defp render(state) do
    content = View.render(BsWeb.GameStateView, "show.json", game_state: state)
    %{content: content}
  end
end
