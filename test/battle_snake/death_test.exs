defmodule BattleSnake.DeathTest do
  alias BattleSnake.Point
  alias BattleSnake.Snake
  alias BattleSnake.World
  alias BattleSnake.Death

  use BattleSnake.Case, async: true
  use BattleSnake.Point

  setup context do
    world = %World{
      max_food: 4,
      height: 10,
      width: 10,
      game_id: 0,
    }
    Map.put context, :world, world
  end

  describe "Death.reap(World.t)" do
    test "removes snakes that died in body collisions", %{world: world} do
      snake = %Snake{coords: [%Point{y: 5, x: 5}, %Point{y: 5, x: 5}]}
      world = put_in world.snakes, [snake]

      world = Death.reap(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake]
    end

    test "removes any snakes that die this turn", %{world: world} do
      snake = %Snake{coords: [%Point{y: 10, x: 10}]}
      world = put_in world.snakes, [snake]

      world = Death.reap(world)
      assert world.snakes == []
      assert world.dead_snakes == [snake]
    end

    @dead_snake %Snake{name: "dead"}
    @snake %Snake{name: "live", coords: [p(-1, 0)]}
    @world %World{turn: 10,
                  snakes: [@snake],
                  dead_snakes: [@dead_snake]}
    test "adds dead snakes to a list of deaths with the turn they died on" do
      world = Death.reap(@world)
      assert world.dead_snakes == [@dead_snake, @snake]
      assert world.snakes == []

      assert world.deaths == [
        %World.DeathEvent{turn: 10, snake: @snake}]
    end
  end

  describe "Death.starvation/1" do
    setup do
      snakes =[build(:snake, id: :dead, health_points: 0),
               build(:snake, id: :alive, health_points: 100)]

      result = Death.starvation(snakes)

      [result: result]
    end

    test "kills snakes that starve this turn", %{result: {live, dead}} do
      assert [%{id: :dead}] = dead
      assert [%{id: :alive}] = live
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert {:starvation, []} == hd(dead).cause_of_death
    end
  end

  describe "Death.wall_collision/1" do
    setup do
      snakes =[
        build(:snake, id: 1, coords: [p(0, 0)]),
        build(:snake, id: 2, coords: [p(0, -1)]),
        build(:snake, id: 3, coords: [p(0, 100)]),
        build(:snake, id: 4, coords: [p(-1, 0)]),
        build(:snake, id: 5, coords: [p(100, 0)]),
      ]

      result = Death.wall_collision(snakes, {100, 100})

      [result: result]
    end

    test "kills snakes the hit a wall", %{result: {live, dead}} do
      assert [5, 4, 3, 2] == (for x <- dead, do: x.id)
      assert [1] == (for x <- live, do: x.id)
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert {:wall_collision, []} == hd(dead).cause_of_death
    end
  end

  describe "Death.collision/1" do
    setup do
      snakes =[
        build(:snake, id: 1, coords: [p(0, 0), p(1, 0), p(2, 0)]),
        build(:snake, id: 2, coords: [p(0, 0), p(1, 0)]),
        build(:snake, id: 3, coords: [p(0, 0), p(1, 0)]),
        build(:snake, id: 4, coords: [p(1, 0)])
      ]

      result = Death.collision(snakes)

      [result: result]
    end

    test "kills snakes the hit another snake", %{result: {live, dead}} do
      dead_ids = (for x <- dead, do: x.id)
      assert 2 in dead_ids
      assert 3 in dead_ids
      assert 4 in dead_ids
      assert length(dead_ids) == 3
      assert [%{id: 1}] = live
    end

    test "sets the cause of death", %{result: {_live, dead}} do
      assert {:collision, _} = hd(dead).cause_of_death
    end

    test "sets who was collided with", %{result: {_live, dead}} do
      assert {_, [collision_head: 1, collision_head: 3]} = hd(dead).cause_of_death
    end
  end
end
