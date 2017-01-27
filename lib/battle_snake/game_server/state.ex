defmodule BattleSnake.GameServer.State do
  alias __MODULE__

  @max_history 20
  @statuses [:cont, :replay, :halt, :suspend]

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
    game_form: {:error, :init},
    hist: [],
    on_change: &State.identity/1,
    on_done: &State.identity/1,
    on_start: &State.identity/1,
    opts: [],
    reducer: &State.identity/1,
    status: :suspend,
    winners: [],
  ]

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

  @spec on_start(t) :: t
  def on_start(state) do
    state.on_start.(state)
  end

  @spec on_change(t) :: t
  def on_change(t) do
    t.on_change.(t)
  end

  def identity(x), do: x

  def step(state) do
    state
    |> save_history()
    |> apply_reducer()
    |> on_change()
  end

  def statuses, do: @statuses

  def step_back(%{hist: []} = s), do: s

  def step_back(state) do
    state
    |> prev_turn
    |> State.on_change()
  end

  def delay(state) do
    opts = state.opts
    Keyword.fetch!(opts, :delay)
  end

  for status <- @statuses do
    method_name = :"#{status}!"
    @spec unquote(method_name)(t) :: t
    def unquote(method_name)(state) do
      put_in(state.status, unquote(status))
    end

    method_name = :"#{status}?"
    @spec unquote(method_name)(t) :: t
    def unquote(method_name)(state) do
      state.status == unquote(status)
    end
  end

  defp prev_turn(state) do
    [h|t] = state.hist
    state = put_in state.world, h
    put_in(state.hist, t)
  end

  defp apply_reducer(%{world: w, reducer: f} = state) do
    %{state| world: f.(w)}
  end

  defp save_history(%{world: h} = state) do
    update_in state.hist, fn t ->
      [h |Enum.take(t, @max_history)]
    end
  end
end
