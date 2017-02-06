defmodule BattleSnake.GameAdminChannel do
  alias BattleSnake.GameServer
  use BattleSnake.Web, :channel

  def join("game_admin:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @command_list ~w(resume next prev)
  def handle_in(command, data, socket) when command in @command_list do
    data = %GameServer.Command{name: command, data: data}
    issue_command(socket, data)
    {:reply, :ok, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp game_id(socket) do
    socket.assigns.game_id
  end

  defp issue_command(socket, data) do
    socket
    |> game_id()
    |> GameServer.PubSub.broadcast!(data)
  end
end
