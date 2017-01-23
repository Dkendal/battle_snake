defmodule BattleSnake.GameServer.State do
  alias __MODULE__

  @type t :: %State{
    world: BattleSnake.World.t,
    reducer: (t -> t),
    on_change: (t-> t),
    opts: [any],
    hist: [t],
    game_form: BattleSnake.GameForm.t
  }

  defstruct [
    :world,
    reducer: &State.identity/1,
    on_change: &State.identity/1,
    on_done: &State.identity/1,
    opts: [],
    hist: [],
    winners: [],
    game_form: {:error, :init},
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

  @spec on_done(t) :: t
  def on_done(state) do
    state.on_done.(state)
  end

  def identity(x), do: x
end
