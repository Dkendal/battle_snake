defmodule BattleSnake.Replay do
  alias __MODULE__
  alias BattleSnake.Replay.Recorder
  alias BattleSnake.Replay.PlayBack

  defdelegate recorder_name(game_id), to: Replay.Registry
  defdelegate play_back_name(game_id), to: Replay.Registry

  def topic(game_id) do
    "replay:#{game_id}"
  end

  def start_recording(game_id) do
    name = recorder_name(game_id)

    case Recorder.Supervisor.start_child([game_id, [name: name]]) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end

  def start_play_back(game_id) do
    name = play_back_name(game_id)

    # case GenServer.start_link(Replay.PlayBack, game_id, name: name) do
    case PlayBack.Supervisor.start_child([game_id, [name: name]]) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end
end

defmodule BattleSnake.Replay.Registry do
  def recorder_name(game_id) do
    {:via, Registry, {BattleSnake.Replay.Registry, "recorder:#{game_id}"}}
  end

  def play_back_name(game_id) do
    {:via, Registry, {BattleSnake.Replay.Registry, "playback:#{game_id}"}}
  end
end

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
