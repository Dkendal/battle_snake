defmodule Bs.RulesTest do
  alias Bs.Rules
  use Bs.Case, async: true

  describe "Rules.last_standing(state)" do
    test "sets the winner to anyone that is still alive" do
      dead_snakes = [
        kill_snake(build(:snake, id: 0), 1),
        kill_snake(build(:snake, id: 1), 2),
        kill_snake(build(:snake, id: 2), 2)
      ]

      snakes = [
        build(:snake, id: 3)
      ]

      world = build(:world, dead_snakes: dead_snakes, snakes: snakes)

      state = build(:state, world: world)

      state = Rules.last_standing(state)

      assert [3] = state.winners
    end

    test "sets the winner to the snake that died last" do
      snakes = [
        kill_snake(build(:snake, id: 0), 1),
        kill_snake(build(:snake, id: 1), 2),
        kill_snake(build(:snake, id: 2), 2)
      ]

      world = build(:world, dead_snakes: snakes)

      state = build(:state, world: world)

      state = Rules.last_standing(state)

      assert [2, 1] = state.winners
    end
  end
end
