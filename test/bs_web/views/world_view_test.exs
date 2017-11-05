defmodule BsWeb.WorldViewTest do
  alias BsWeb.WorldView

  use Bs.Case, async: true
  use Bs.Point

  @snake build(:snake, id: 1)

  @world build(:world, snakes: [@snake], food: [p(0, 0)], dead_snakes: [
           build(:snake, id: 2)
         ])

  test "v2" do
    actual =
      Phoenix.View.render(
        WorldView,
        "show.json",
        v: 2,
        world: @world,
        snake: @snake
      )

    expected = %{
      food: %{data: [%{object: :point, x: 0, y: 0}], object: :list},
      height: 10,
      id: 0,
      object: :world,
      snakes: %{
        data: [
          %{
            body: %{data: [%{object: :point, x: 0, y: 0}], object: :list},
            health: 100,
            id: 1,
            length: 1,
            name: "",
            object: :snake,
            taunt: ""
          }
        ],
        object: :list
      },
      turn: 0,
      width: 10,
      you: %{
        body: %{data: [%{object: :point, x: 0, y: 0}], object: :list},
        health: 100,
        id: 1,
        length: 1,
        name: "",
        object: :snake,
        taunt: ""
      }
    }

    assert actual == expected
  end

  test "v1" do
    actual =
      Phoenix.View.render(
        WorldView,
        "show.json",
        v: 1,
        world: @world,
        snake: @snake
      )

    expected = %{
      food: [[0, 0]],
      game_id: 0,
      height: 10,
      dead_snakes: [
        %{
          coords: [[0, 0]],
          health_points: 100,
          id: 2,
          name: "",
          taunt: ""
        }
      ],
      snakes: [
        %{
          coords: [[0, 0]],
          health_points: 100,
          id: 1,
          name: "",
          taunt: ""
        }
      ],
      turn: 0,
      width: 10,
      you: 1
    }

    assert actual == expected
  end
end
