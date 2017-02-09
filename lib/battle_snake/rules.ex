defmodule BattleSnake.Rules do
  alias BattleSnake.GameServer.State
  alias BattleSnake.World

  @spec last_standing(State.t) :: State.t
  def last_standing(state) do
    put_in(state.winners, do_last_standing(state))
  end

  def do_last_standing(%State{} = state) do
    do_last_standing(state.world)
  end

  def do_last_standing(%World{snakes: []} = world) do
    {_turn, deaths} = world.deaths
    |> Enum.group_by(&(&1.turn))
    |> Enum.max_by(fn {turn, _} -> turn end)
    for %{snake: snake} <- deaths, do: snake
  end

  def do_last_standing(%World{} = world) do
    world.snakes
  end
end
