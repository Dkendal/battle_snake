defmodule BattleSnake.Api.GameServerController do
  alias BattleSnake.GameServer

  use BattleSnake.Web, :controller

  def create(conn, %{"id" => id}) do
    response = GameServer.Registry.lookup_or_create(id)
    |> do_create
    json(conn, response)
  end

  defp do_create({:ok, pid}) do
    GameServer.resume(pid)
    :ok
  end

  defp do_create({:error, e}), do: %{error: Exception.message(e)}
end
