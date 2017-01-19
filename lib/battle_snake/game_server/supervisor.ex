defmodule BattleSnake.GameServer.Supervisor do
  use Supervisor

  @name __MODULE__

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_game_server(opts) do
    Supervisor.start_child(@name, opts)
  end

  def init(:ok) do
    children = [
      worker(BattleSnake.GameServer, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
