defmodule BattleSnake.Replay.PlayBack.Supervisor do
  use Supervisor
  alias BattleSnake.Replay

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(opts) do
    Supervisor.start_child(__MODULE__, opts)
  end

  def init(:ok) do
    children = [
      worker(Replay.PlayBack, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule BattleSnake.Replay.Recorder.Supervisor do
  use Supervisor
  alias BattleSnake.Replay

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(opts) do
    Supervisor.start_child(__MODULE__, opts)
  end

  def init(:ok) do
    children = [
      worker(Replay.Recorder, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end

defmodule BattleSnake.Replay.Supervisor do
  use Supervisor
  alias BattleSnake.Replay

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Replay.PlayBack.Supervisor, []),
      supervisor(Replay.Recorder.Supervisor, []),
      supervisor(Registry,
        [:unique, BattleSnake.Replay.Registry],
        [id: BattleSnake.Replay.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
