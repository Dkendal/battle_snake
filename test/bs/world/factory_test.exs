defmodule Bs.World.FactoryTest do
  alias Bs.World.Factory
  alias Bs.World
  alias Bs.Snake

  use Bs.Case, async: false

  @url "http://example.com/start"
  @json "{\"width\":10,\"height\":10,\"game_id\":1}"
  @moduletag :capture_log

  setup do
    mock(HTTPoison)

    on_exit(&unload/0)

    game_form =
      build(:game_form, height: 10, width: 10, id: 1, snakes: [
        build(:snake_form)
      ])

    [game_form: game_form]
  end

  test "#build when snakes respond", c do
    expect(HTTPoison, :post!, fn @url, @json, _, _ ->
      %HTTPoison.Response{
        status_code: 200,
        body: encode!(%{
          name: "example snake",
          taunt: "example taunt"
        })
      }
    end)

    world = Factory.build(c.game_form)

    assert [%{coords: coords}] = world.snakes

    assert [_, _, _] = coords

    assert %World{
             game_form_id: 1,
             height: 10,
             width: 10,
             max_food: 1,
             game_id: 1,
             food: world.food,
             snakes: [
               %Snake{
                 coords: coords,
                 url: "http://example.com",
                 taunt: "example taunt",
                 name: "example snake"
               }
             ]
           } == world
  end

  test "when a request fails", c do
    expect(HTTPoison, :post!, fn @url, @json, _, _ -> raise "expected failure" end)

    world = Factory.build(c.game_form)

    assert world.snakes == []
  end
end
