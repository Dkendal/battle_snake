defmodule BattleSnake.Api.GameServerController do
  alias BattleSnake.{
    GameForm,
    GameServer
  }

  use BattleSnake.Web, :controller

  def create(conn, %{"id" => id}) do
    try do
      id
      |> GameServer.Registry.lookup()
      |> do_create(id: id)

      json conn, :ok
    rescue
      e ->
        json conn, %{error: e.message}
    end
  end

  def do_create([], id: id) do
    GameForm.get(id)
    |> do_create(id: id)
  end

  def do_create([{pid, _}], _) when is_pid(pid) do
    raise "game server already started"
  end

  def do_create({:error, e}, _) do
    raise e
  end

  def do_create({:ok, %GameForm{} = game_form}, id: id) do
    state = BattleSnake.GameServerConfig.setup(game_form, on_change())
    {:ok, game_server_pid} = GameServer.Registry.create(id, state)
    GameServer.resume(game_server_pid)
  end

  defp on_change() do
    fn state ->
      require Logger
      Logger.debug "tick | pid: #{inspect self()} | turn: #{state.world.turn}"
      state
    end
  end
end
