defmodule Bs.Rules do
  def last_standing(state) do
    world = state.world
    live = world.snakes
    dead = world.dead_snakes
    winners = do_last_standing(live, dead)
    put_in(state.winners, winners)
  end

  defp do_last_standing([], dead) do
    mapper = & &1.death.turn

    reduce_while = fn
      snake, [] ->
        {:cont, [snake]}

      %{death: %{turn: t}} = s, [%{death: %{turn: t}} | _] = acc ->
        {:cont, [s | acc]}

      _, acc ->
        {:halt, acc}
    end

    map_finish = & &1.id

    dead
    |> Enum.sort_by(mapper, &>=/2)
    |> Enum.reduce_while([], reduce_while)
    |> Enum.map(map_finish)
  end

  defp do_last_standing(live, _dead) do
    for s <- live, do: s.id
  end
end
