defmodule BsWeb.GameAdminChannel do
  require Logger

  alias Bs.Game

  use BsWeb, :channel

  def join("admin", %{"id" => id}, socket) do
    socket = assign(socket, :id, id)
    # IO.inspect Game.Registry.whereis_name id
    {:ok, socket}
  end

  def handle_in("stop", _params, socket) do
    Game.restart(socket.assigns.id)
    {:reply, :ok, socket}
  end

  def handle_in("next", _params, socket) do
    Game.next(socket.assigns.id)
    {:reply, :ok, socket}
  end

  def handle_in("prev", _params, socket) do
    Game.prev(socket.assigns.id)
    {:reply, :ok, socket}
  end

  def handle_in("resume", _params, socket) do
    Game.resume(socket.assigns.id)
    {:reply, :ok, socket}
  end

  def handle_in("pause", _params, socket) do
    Game.pause(socket.assigns.id)
    {:reply, :ok, socket}
  end

  def handle_in(_action, _params, socket) do
    {:reply, :error, socket}
  end

  def handle_info(_info, socket) do
    {:reply, :error, socket}
  end
end
