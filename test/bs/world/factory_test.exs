defmodule Bs.World.FactoryTest do
  alias Bs.World.Factory
  alias Bs.World
  alias Bs.Snake

  use Bs.Case, async: false

  test "#build when snakes respond" do
    game_form = build(:game_form, id: 1, snakes: [build(:snake_form)])

    world = Factory.build(game_form)

    food = world.food

    assert [%{coords: coords}] = world.snakes

    assert [_, _, _] = coords

    assert %World{
             id: _,
             game_form_id: 1,
             height: 20,
             width: 20,
             max_food: 1,
             game_id: 1,
             food: ^food,
             snakes: [
               %Snake{
                 coords: ^coords,
                 url: "up.mock",
                 taunt: "mock taunt",
                 name: "mock snake"
               }
             ]
           } = world
  end

  test "when a request fails" do
    game_form =
      build(
        :game_form,
        id: 1,
        snakes: [
          build(:snake_form, url: "econnrefused.mock")
        ]
      )

    world = Factory.build(game_form)

    assert world.snakes == []
  end
end
