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

  @spec done?(t) :: boolean
  def done?(state) do
    opts = state.opts
    world = state.world
    fun = Keyword.fetch!(opts, :objective)
    fun.(world)
  end

  def identity(x), do: x
end
