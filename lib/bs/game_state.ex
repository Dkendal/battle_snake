defmodule Bs.GameState do
  alias Bs.Death
  alias Bs.Movement
  alias Bs.Snake
  alias Bs.World

  @max_history 20

  @statuses [:cont, :replay, :halted, :suspend]

  defstruct [
    :world,
    :objective,
    :game_form_id,
    snakes: %{},
    game_form: {:error, :init},
    delay: 0,
    hist: [],
    status: :suspend,
    winners: [],
    done?: false
  ]

  ####################
  # Type Definitions #
  ####################

  def cont!(state) do
    put_in(state.status, :cont)
  end

  def cont?(state) do
    state.status == :cont
  end

  def suspend!(state) do
    put_in(state.status, :suspend)
  end

  def suspend?(state) do
    state.status == :suspend
  end

  def halted!(state) do
    put_in(state.status, :halted)
  end

  def halted?(state) do
    state.status == :halted
  end

  def replay!(state) do
    put_in(state.status, :replay)
  end

  def replay?(state) do
    state.status == :replay
  end

  defmacrop is_replay(state) do
    quote do
      %__MODULE__{status: :replay} = unquote(state)
    end
  end

  def done?(state) do
    state.objective.(state.world)
  end

  def identity(x), do: x

  # TODO change :hist to {forward, backward} so that that
  # history is not lost when watching a replay
  def step(is_replay(state)) do
    case state.hist do
      [] ->
        halted!(state)

      [h | t] ->
        state = put_in(state.world, h)
        state = put_in(state.hist, t)
        state
    end
  end

  def step(state) do
    state =
      state
      |> save_history
      |> Movement.next()
      |> Death.reap()
      |> Map.update!(:world, &World.step/1)

    if done?(state), do: step_done(state), else: state
  end

  @doc """
  Sets the winners to be anyone that is still alive, or whoever died last.
  """
  def set_winners(state) do
    winners = for s <- state.world.snakes, do: s.id
    winners = if length(winners) != 0, do: winners, else: who_died_last(state)
    winners = MapSet.new(winners)
    put_in(state.winners, winners)
  end

  def statuses, do: @statuses

  def step_back(%{hist: []} = s), do: s

  def step_back(state) do
    prev_turn(state)
  end

  def delay(state) do
    state.delay
  end

  def winner?(state, %Snake{} = snake) do
    winner?(state, snake.id)
  end

  def winner?(state, snake_id) do
    Enum.member?(state.winners, snake_id)
  end

  def objective(state) do
    state.objective.(state.world)
  end

  defdelegate(fetch(state, key), to: Map)

  #####################
  # Private Functions #
  #####################

  defp prev_turn(state) do
    [h | t] = state.hist
    state = put_in(state.world, h)
    put_in(state.hist, t)
  end

  defp save_history(%{world: h} = state) do
    update_in(state.hist, fn t -> [h | Enum.take(t, @max_history)] end)
  end

  defp who_died_last(state) do
    map_fun = & &1.id

    groups = Enum.group_by(state.world.dead_snakes, &Snake.died_on/1, map_fun)

    if Enum.count(groups) > 0 do
      groups
      |> Enum.max_by(&elem(&1, 0))
      |> elem(1)
    else
      []
    end
  end

  defp step_done(state) do
    state = set_winners(state)
    state = put_in(state.done?, true)
    send_game_done()
    state
  end

  defp send_game_done do
    send(self(), :game_done)
  end
end
