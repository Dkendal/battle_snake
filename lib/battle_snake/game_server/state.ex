defmodule BattleSnake.GameServer.State do
  alias __MODULE__

  alias BattleSnake.World

  defmodule Event, do: defstruct([:name, :data])

  @max_history 20

  @statuses [:cont, :replay, :halted, :suspend]

  @spec cont!(t) :: t
  def cont!(state) do
    put_in(state.status, :cont)
  end

  @spec cont?(t) :: t
  def cont?(state) do
    state.status == :cont
  end

  defmacrop is_cont(state) do
    quote do
      %__MODULE__{status: :cont} = unquote(state)
    end
  end

  defoverridable("cont!": 1, "cont?": 1)

  @spec suspend!(t) :: t
  def suspend!(state) do
    put_in(state.status, :suspend)
  end

  @spec suspend?(t) :: t
  def suspend?(state) do
    state.status == :suspend
  end

  defmacrop is_suspend(state) do
    quote do
      %__MODULE__{status: :suspend} = unquote(state)
    end
  end

  defoverridable("suspend!": 1, "suspend?": 1)

  @spec halted!(t) :: t
  def halted!(state) do
    put_in(state.status, :halted)
  end

  @spec halted?(t) :: t
  def halted?(state) do
    state.status == :halted
  end

  defmacrop is_halted(state) do
    quote do
      %__MODULE__{status: :halted} = unquote(state)
    end
  end

  defoverridable("halted!": 1, "halted?": 1)

  @spec replay!(t) :: t
  def replay!(state) do
    put_in(state.status, :replay)
  end

  @spec replay?(t) :: t
  def replay?(state) do
    state.status == :replay
  end

  defmacrop is_replay(state) do
    quote do
      %__MODULE__{status: :replay} = unquote(state)
    end
  end

  defoverridable("replay!": 1, "replay?": 1)

  @typedoc """
  Any function that takes a State, and returns a new State.
  """
  @type state_fun :: (t -> t)

  @type state_predicate :: (t -> boolean)

  @typedoc """
  A function that, when true, indicates that the game is over.
  """
  @type objective_fun :: state_predicate

  @type t :: %State{
    world: World.t,
    on_change: state_fun,
    on_done: state_fun,
    on_start: state_fun,
    objective: objective_fun,
    delay: non_neg_integer,
    hist: [World.t],
    game_form: BattleSnake.GameForm.t
  }

  @events [
    :on_change,
    :on_done,
    :on_start,
  ]

  defstruct([
    :world,
    :objective,
    :game_form_id,
    game_form: {:error, :init},
    delay: 0,
    hist: [],
    status: :suspend,
    winners: [],
  ] ++ for(event <- @events, do: {event, &State.identity/1}))

  @spec done?(t) :: boolean
  def done?(state) do
    state.objective.(state.world)
  end

  @doc "Execute the on_done event-handler function"
  @spec on_done(t) :: t
  def on_done(state) do
    state.on_done.(state)
  end

  @doc "Put a new on_done event-handler function into state"
  @spec on_done(t, (t -> t)) :: t
  def on_done(state, handler) do
    put_in(state.on_done, handler)
  end

  @doc "Execute the on_start event-handler function"
  @spec on_start(t) :: t
  def on_start(state) do
    state.on_start.(state)
  end

  @doc "Put a new on_start event-handler function into state"
  @spec on_start(t, (t -> t)) :: t
  def on_start(state, handler) do
    put_in(state.on_start, handler)
  end

  @doc "Execute the on_change event-handler function"
  @spec on_change(t) :: t
  def on_change(state) do
    state.on_change.(state)
  end

  @doc "Put a new on_change event-handler function into state"
  @spec on_change(t, (t -> t)) :: t
  def on_change(state, handler) do
    put_in(state.on_change, handler)
  end

  def identity(x), do: x

  # TODO change :hist to {forward, backward} so that that
  # history is not lost when watching a replay
  def step(is_replay(state)) do
    case state.hist do
      [] ->
        halted!(state)

      [h|t] ->
        state = put_in(state.world, h)
        state = put_in(state.hist, t)
        state
        |> on_change()
    end
  end

  def step(state) do
    state
    |> save_history()
    |> BattleSnake.Movement.next()
    |> BattleSnake.Death.reap()
    |> Map.update!(:world, &World.step/1)
    |> on_change()
  end

  @doc "Loads the game history for a game matching this id"
  @spec load_history(t) :: t
  def load_history(state) do
    # TODO use qlc or something more efficient rather than sorting results here.
    hist =
      World
      |> :mnesia.dirty_index_read(state.game_form_id, :game_form_id)
      |> Enum.map(&Mnesia.Repo.load/1)
      |> Enum.sort_by((& Map.get &1, :turn))
    put_in(state.hist, hist)
  end

  def statuses, do: @statuses

  def step_back(%{hist: []} = s), do: s

  def step_back(state) do
    state
    |> prev_turn
    |> State.on_change()
  end

  def delay(state) do
    state.delay
  end

  def objective(state) do
    state.objective.(state.world)
  end

  defp prev_turn(state) do
    [h|t] = state.hist
    state = put_in state.world, h
    put_in(state.hist, t)
  end

  defp save_history(%{world: h} = state) do
    update_in state.hist, fn t ->
      [h |Enum.take(t, @max_history)]
    end
  end
end
