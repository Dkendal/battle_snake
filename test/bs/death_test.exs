defmodule DeathTest do
  alias Bs.Case
  alias Bs.Death
  alias Bs.Point
  alias Death.BodyCollisionCause
  alias Death.HeadCollisionCause
  alias Death.SelfCollisionCause
  alias Death.StarvationCause
  alias Death.WallCollisionCause

  use Case, async: true
  use Point

  describe "Death.reap/1" do
    setup do
      snakes = [
        build(:snake, id: 0, coords: [p(1, 1)]),
        build(:snake, id: 1, coords: [p(0, 0), p(1, 0)], health_points: 0),
        build(:snake, id: 2, coords: [p(0, 0)]),
        build(:snake, id: 3, coords: [p(1, 0), p(2, 0), p(3, 0)]),
        build(:snake, id: 4, coords: [p(101, 0)]),
        build(:snake, id: 5, coords: [p(0, 0)]),
        build(:snake, id: 6, coords: [p(9, 0), p(9, 0)])
      ]

      world = build(:world, width: 100, height: 100, snakes: snakes)
      state = build(:state, world: world)

      state = Death.reap(state)

      [state: state]
    end

    test "updates who dies and who lives this turn", %{state: state} do
      live = state.world.snakes
      dead = state.world.dead_snakes

      assert [0] == for(x <- live, do: x.id)
      assert [1, 2, 3, 4, 5, 6] == for(x <- dead, do: x.id)
    end

    test "sets the cause of death", %{state: state} do
      dead = state.world.dead_snakes

      causes = for x <- dead, do: {x.id, x.death}

      assert [
               {1, %Death{turn: 0, causes: [%StarvationCause{}]}},
               {
                 2,
                 %Death{
                   turn: 0,
                   causes: [
                     %HeadCollisionCause{with: 1},
                     %HeadCollisionCause{with: 5}
                   ]
                 }
               },
               {3, %Death{turn: 0, causes: [%BodyCollisionCause{with: 1}]}},
               {4, %Death{turn: 0, causes: [%WallCollisionCause{}]}},
               {
                 5,
                 %Death{
                   turn: 0,
                   causes: [
                     %HeadCollisionCause{with: 1},
                     %HeadCollisionCause{with: 2}
                   ]
                 }
               },
               {6, %Death{turn: 0, causes: [%SelfCollisionCause{}]}}
             ] == causes
    end
  end

  describe "Death.starvation/1" do
    setup do
      snakes = [
        build(:snake, id: :dead, health_points: 0),
        build(:snake, id: :alive, health_points: 100)
      ]

      result = Death.starvation(snakes)

      [result: result]
    end

    test "kills snakes that starve this turn", %{result: {live, dead}} do
      assert [%{id: :dead}] = dead
      assert [%{id: :alive}] = live
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert [%StarvationCause{}] == hd(dead).death
    end
  end

  describe "Death.wall_collision/1" do
    setup do
      snakes = [
        build(:snake, id: 1, coords: [p(0, 0)]),
        build(:snake, id: 2, coords: [p(0, -1)]),
        build(:snake, id: 3, coords: [p(0, 100)]),
        build(:snake, id: 4, coords: [p(-1, 0)]),
        build(:snake, id: 5, coords: [p(200, 0)]),
        build(:snake, id: 6, coords: [p(150, 0)])
      ]

      result = Death.wall_collision(snakes, {200, 100})

      [result: result]
    end

    test "kills snakes the hit a wall", %{result: {live, dead}} do
      assert [5, 4, 3, 2] == for(x <- dead, do: x.id)
      assert [6, 1] == for(x <- live, do: x.id)
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert [%WallCollisionCause{}] == hd(dead).death
    end
  end

  describe ".collision" do
    setup do
      snakes = [
        build(:snake, id: 1, coords: [p(0, 0), p(1, 0), p(2, 0)]),
        build(:snake, id: 2, coords: [p(0, 0), p(1, 0)]),
        build(:snake, id: 3, coords: [p(0, 0), p(1, 0)]),
        build(:snake, id: 4, coords: [p(1, 0)])
      ]

      result = Death.collision(snakes)

      [result: result]
    end

    test "kills snakes the hit another snake", %{result: {live, dead}} do
      dead_ids = for x <- dead, do: x.id
      assert 2 in dead_ids
      assert 3 in dead_ids
      assert 4 in dead_ids
      assert length(dead_ids) == 3
      assert [%{id: 1}] = live
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert [%HeadCollisionCause{with: 1}, %HeadCollisionCause{with: 3}] ==
               hd(dead).death
    end

    test "head collisions are still counted when the tail is stacked" do
      snakes = [
        build(:snake, id: 1, coords: [p(0, 0), p(1, 0), p(1, 0)]),
        build(:snake, id: 2, coords: [p(0, 0), p(0, 1)])
      ]

      import Access

      assert [[%HeadCollisionCause{with: 1}]] ==
               snakes
               |> Death.collision()
               |> get_in([elem(1), all(), :death])
    end
  end

  describe "Death.combine_dead/1" do
    setup do
      snakes = [
        s1 = build(:snake, id: 1, coords: [p(0, 0)]),
        s2 = build(:snake, id: 2),
        s3 = build(:snake, id: 3),
        build(:snake, id: 4)
      ]

      cause_a = {:kill_a, []}
      cause_b = {:kill_b, []}
      cause_c = {:kill_c, []}

      l = [
        [%{s1 | death: [cause_a]}],
        [%{s1 | death: [cause_b]}, s2],
        [%{s1 | death: [cause_c]}, s3]
      ]

      result = Death.combine_dead(l, 0)

      [result: result, snakes: snakes]
    end

    test "returns the union of the results", %{result: result} do
      assert is_list(result), inspect(result)
      assert [1, 2, 3] == for(x <- result, do: x.id)
    end

    test "merges the causes of death", %{result: result} do
      [s1 | _] = result
      causes = [kill_c: [], kill_b: [], kill_a: []]
      assert %Death{turn: 0, causes: causes} == s1.death
    end
  end

  describe "Death.combine_live/1" do
    test "returns the intersection of the results" do
      [s1, s2, s3, s4] = build_list(4, :snake, id: sequence("snake"))

      l = [[s1, s2, s3], [s1, s3], [s3, s4]]

      result = Death.combine_live(l)

      assert is_list(result)

      assert MapSet.new([s1, s3]) == result |> MapSet.new()
    end
  end
end
