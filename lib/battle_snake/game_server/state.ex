defmodule BattleSnake.GameServer.State do
  alias __MODULE__

  alias BattleSnake.{
    World,
    GameServer,
  }

  defmodule Event, do: defstruct([:name, :data])

  @max_history 20
  @statuses [:cont, :replay, :halted, :suspend]

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

    method_name = :"is_#{status}"
    defmacrop unquote(method_name)(state) do
      status = unquote(status)
      quote do
        %__MODULE__{status: unquote(status)} = unquote(state)
      end
    end

    defoverridable("#{status}!": 1, "#{status}?": 1)
  end

  # TODO remove opts attr with actual attributes.
  @type t :: %State{
    world: World.t,
    reducer: (t -> t),
    on_change: (t-> t),
    opts: [any],
    hist: [World.t],
    game_form: BattleSnake.GameForm.t
  }

  @events [
    :on_change,
    :on_done,
    :on_start,
    :reducer,
  ]

  defstruct([
    :world,
    :game_form_id,
    game_form: {:error, :init},
    hist: [],
    opts: [],
    status: :suspend,
    winners: [],
  ] ++ for(event <- @events, do: {event, &State.identity/1}))

  @spec done?(t) :: boolean
  def done?(state) do
    opts = state.opts
    world = state.world
    fun = Keyword.fetch!(opts, :objective)
    fun.(world)
  end

  for event <- @events do
    method_name = event
    @doc "Execute the #{method_name} event-handler function"
    @spec unquote(method_name)(t) :: t
    def unquote(method_name)(state) do
      state.unquote(method_name).(state)
    end

    method_name = :"put_#{event}"
    @doc "Put a new #{method_name} event-handler function into state"
    @spec unquote(method_name)(t, (t -> t)) :: t
    def unquote(method_name)(state, handler) do
      put_in(state.unquote(method_name), handler)
    end
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
    |> broadcast(:tick)
  end

  def step(state) do
    state
    |> save_history()
    |> apply_reducer()
    |> on_change()
    |> broadcast(:tick)
  end

  @doc "Loads the game history for a game matching this id"
  @spec load_history(t) :: t
  def load_history(state) do
    # TODO use qlc or something more efficient rather than sorting results here.
    hist =
      World.table_name()
      |> :mnesia.dirty_index_read(state.game_form_id, :game_form_id)
      |> Enum.map(&World.load/1)
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
    opts = state.opts
    Keyword.fetch!(opts, :delay)
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

  defp broadcast(state, event) do
    topic = topic(state)
    event = %Event{name: event, data: state}
    GameServer.PubSub.broadcast(topic, event)
    state
  end

  defp topic(state) do
    state.game_form_id
  end
end
