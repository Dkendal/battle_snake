defmodule BattleSnake do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BattleSnakeWeb.Endpoint, []),
      supervisor(BattleSnake.GameServer.Supervisor, []),
      supervisor(Task.Supervisor, [[name: BattleSnake.MoveSupervisor]]),
      supervisor(Registry, [:unique, BattleSnake.GameServer.Registry]),
      supervisor(Phoenix.PubSub.PG2, [BattleSnake.GameServer.PubSub, []]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BattleSnake.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
