defmodule BattleSnake.Replay do
end

defmodule BattleSnake.Replay.PlayBack do
  alias __MODULE__
  use GenServer
  require Record

  @attributes [:receiver, :replay_speed, :frames, :topic]
  defstruct(@attributes)
  defmodule Frame, do: defstruct([:data])

  def init(topic, frames, receiver, replay_speed) do
    new_state = struct(__MODULE__,
      topic: topic,
      replay_speed: replay_speed,
      receiver: receiver,
      frames: frames)

    {:ok, new_state}
  end

  def handle_cast(:play, s) do
    {:noreply, s}
  end

  def handle_info(:broadcast, %{frames: []} = s) do
    {:stop, :normal, s}
  end

  def handle_info(:broadcast, s) do
    %PlayBack{
      frames: [frame | rest],
      replay_speed: time,
      receiver: receiver
    } = s

    Process.send_after(self(), :broadcast, time)

    send(receiver, %Frame{data: frame})

    new_state = struct(s, frames: rest)

    {:noreply, new_state}
  end
end

defmodule BattleSnake.Replay.Recorder do
  use GenServer
end

defmodule BattleSnake.Replay.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      supervisor(Registry, [:unique, BattleSnake.Replay.Registry], [id: BattleSnake.Replay.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
