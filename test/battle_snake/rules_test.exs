defmodule BattleSnake.RulesTest do
  use ExUnit.Case, async: true

  @living_snake_a %BattleSnake.Snake{name: "living a"}
  @living_snake_b %BattleSnake.Snake{name: "living b"}

  @dead_snake_10 %BattleSnake.Snake{name: "dead 10"}
  @dead_snake_20_a %BattleSnake.Snake{name: "dead 20 a"}
  @dead_snake_20_b %BattleSnake.Snake{name: "dead 20 b"}

  @deaths [
    %BattleSnake.World.DeathEvent{turn: 10, snake: @dead_snake_10},
    %BattleSnake.World.DeathEvent{turn: 20, snake: @dead_snake_20_a},
    %BattleSnake.World.DeathEvent{turn: 20, snake: @dead_snake_20_b}
  ]

  @state_with_living %BattleSnake.GameServer.State{
    world: %BattleSnake.World{
      snakes: [@living_snake_a, @living_snake_b],
      deaths: @deaths}}

  @state_all_dead %BattleSnake.GameServer.State{
    world: %BattleSnake.World{
      snakes: [],
      deaths: @deaths}}

  describe "BattleSnake.Rules.last_standing/1" do
    test "sets the winners" do
      state = BattleSnake.Rules.last_standing(@state_with_living)
      assert [@living_snake_a, @living_snake_b] == state.winners
    end
  end

  describe "BattleSnake.Rules.do_last_standing/1" do
    test "any snakes that are still alive are considered the winner" do
      assert [@living_snake_a, @living_snake_b] ==
        BattleSnake.Rules.do_last_standing(@state_with_living)
    end

    test "if there are no living snakes the snakes the died on the last turn " <>
      "are considered to be the winner" do
      assert [@dead_snake_20_a, @dead_snake_20_b] ==
        BattleSnake.Rules.do_last_standing(@state_all_dead)
    end
  end
end
