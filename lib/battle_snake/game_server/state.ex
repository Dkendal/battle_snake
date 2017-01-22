defmodule BattleSnake.GameServer.State do
  alias __MODULE__

  @type t :: %State{
    world: BattleSnake.World.t,
    reducer: (t -> t),
    on_change: (t-> t),
    opts: [any],
    hist: [t]
  }

  defstruct [
    :world,
    reducer: &State.identity/1,
    on_change: &State.identity/1,
    opts: [],
    hist: []
  ]

  @spec change(t) :: t
  def change(t) do
    t.on_change.(t)
    t
  end

  def identity(x), do: x
end
