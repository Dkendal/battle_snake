defmodule Bs do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(BsWeb.Endpoint, []),
      supervisor(Bs.Game.Supervisor, []),
      supervisor(Task.Supervisor, [[name: Bs.MoveSupervisor]]),
      supervisor(Registry, [:unique, Bs.Game.Registry]),
      supervisor(Phoenix.PubSub.PG2, [Bs.Game.PubSub, []]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
