defmodule BsWeb.GameAdminChannel do
  alias Phoenix.Socket
  alias Bs.Game
  use BsWeb, :channel

  @requests ~w(resume next prev replay pause)

  def join("game_admin:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)
      pid = game_server(game_id)
      socket = assign(socket, :game_server_pid, pid)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def available_requests, do: @requests

  def handle_in("stop", _from, socket) do
    id = game_id socket

    case Game.Registry.find id do
      {:ok, pid} ->
        ref = Process.monitor(pid)

        GenServer.stop(pid)

        receive do
          {:DOWN, ^ref, _, _, _} ->
            :ok
        end

      :error ->
        :ok
    end

    {:ok, _pid} = Game.find id

    {:noreply, socket}
  end

  def handle_in(request, from, socket) when request in @requests do
    request = String.to_existing_atom(request)
    handle_in(request, from, socket)
  end

  def handle_in(request, _from, socket) when is_atom(request) do
    pid = Game.find!(game_id(socket))
    GenServer.call(pid, request)
    {:noreply, socket}
  end

  def handle_in(request, _from, socket) do
    {:reply,
     {:error,
      %{error: "\"#{request}\" is not a valid request. Valid requests: #{inspect @requests}"}},
     socket}
  end

  def handle_info(_info, socket) do
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp game_id(%Socket{} = socket) do
    socket.assigns.game_id
  end

  defp game_server(%Socket{} = socket) do
    socket.assigns.game_server_pid
  end

  defp game_server(game_id) when is_binary(game_id) do
    Game.find!(game_id)
  end
end
