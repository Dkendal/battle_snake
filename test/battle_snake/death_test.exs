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

      world = build(:world, snakes: snakes)

      state = build(:state, world: world)

      state = Death.starvation(state)

      [state: state]
    end

    test "kills snakes that starve this turn", %{state: state} do
      assert [%{id: :dead}] = state.world.dead_snakes
      assert [%{id: :alive}] = state.world.snakes
    end

    test "sets the cause of death", %{state: state} do
      assert {:starvation, []} == hd(state.world.dead_snakes).cause_of_death
    end
  end

  describe "Death.wall_collision/1" do
    setup do
      snakes =[build(:snake, id: :dead, coords: [p(-1, -1)]),
               build(:snake, id: :alive, coords: [p(0, 0)])]

      world = build(:world, snakes: snakes, width: 100, height: 100)

      state = build(:state, world: world)

      state = Death.wall_collision(state)

      [state: state]
    end

    test "kills snakes the hit a wall", %{state: state} do
      assert [%{id: :dead}] = state.world.dead_snakes
      assert [%{id: :alive}] = state.world.snakes
    end

    test "sets the cause of death", %{state: state} do
      assert {:wall_collision, []} == hd(state.world.dead_snakes).cause_of_death
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

      world = build(:world, snakes: snakes)

      state = build(:state, world: world)

      state = Death.collision(state)

      [state: state]
    end

    test "kills snakes the hit another snake", %{state: state} do
      dead = (for x <- state.world.dead_snakes, do: x.id)
      assert 2 in dead
      assert 3 in dead
      assert 4 in dead
      assert length(dead) == 3
      assert [%{id: 1}] = state.world.snakes
    end

    test "sets the cause of death", %{state: state} do
      assert {:collision, _} = hd(state.world.dead_snakes).cause_of_death
    end

    test "sets who was collided with", %{state: state} do
      assert {_, [collision_head: 1, collision_head: 3]} = hd(state.world.dead_snakes).cause_of_death
    end
  end
end
