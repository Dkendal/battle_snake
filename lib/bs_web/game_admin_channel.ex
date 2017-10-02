defmodule BsWeb.GameAdminChannel do
  require Logger

  alias Bs.Game

  use BsWeb, :channel

  def join("game_admin:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign socket, :id, game_id

      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("stop", _params, socket) do
    Game.restart socket.assigns.id
    {:reply, :ok, socket}
  end

  def handle_in("next", _params, socket) do
    Game.next socket.assigns.id
    {:reply, :ok, socket}
  end

  def handle_in("prev", _params, socket) do
    Game.prev socket.assigns.id
    {:reply, :ok, socket}
  end

  def handle_in("resume", _params, socket) do
    Game.resume socket.assigns.id
    {:reply, :ok, socket}
  end

  def handle_in("pause", _params, socket) do
    Game.pause socket.assigns.id
    {:reply, :ok, socket}
  end

  def handle_in(_action, _params, socket) do
    {:reply, :error, socket}
  end

  def handle_info(_info, socket) do
    {:reply, :error, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
