defmodule Bs.World.FactoryTest do
  alias Bs.World.Factory

  use Bs.Case, async: false

  test "#build populates the world" do
    game_form = build(:game_form, id: 1, snakes: [])

    world = Factory.build(game_form)

    assert world.game_form_id == 1
    assert world.height == 20
    assert world.width == 20
    assert world.max_food == 1
    assert world.game_id == 1
    assert length(world.food) == 1
    assert length(world.snakes) == 0
  end

  test "#build when snakes respond" do
    Bs.ApiMock
    |> expect(:start, fn "snake1", _, _ ->
      %Response{body: encode!(%{name: "name", taunt: "taunt"})}
    end)

    game_form =
      build(:game_form, id: 1, snakes: [build(:snake_form, url: "snake1")])

    world = Factory.build(game_form)

    assert length(world.snakes) == 1

    [snake] = world.snakes

    assert snake.url == "snake1"
    assert snake.taunt == "taunt"
    assert snake.name == "name"
    assert length(snake.coords) == 3
    assert snake.status.type == :alive
  end

  test "when a request fails" do
    Bs.ApiMock
    |> expect(:start, fn "snake1", _, _ ->
      raise Error
    end)

    game_form =
      build(:game_form, id: 1, snakes: [build(:snake_form, url: "snake1")])

    world = Factory.build(game_form)

    assert length(world.snakes) == 0
    assert length(world.dead_snakes) == 1

    [snake] = world.dead_snakes

    assert snake.url == "snake1"
    assert snake.status.type == :connection_failure
    assert snake.coords |> length == 0
  end
end
