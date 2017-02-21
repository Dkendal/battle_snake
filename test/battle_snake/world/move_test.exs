defmodule BattleSnake.World.MoveTest do
  alias BattleSnake.World.Move
  use BattleSnake.Case, async: false
  use BattleSnake.Point
  import BattleSnake.Point

  def request_move(%{name: :good_snake}, _world, _) do
    json = %{move: "down"}
    body = Poison.encode!(json)
    {:ok, %HTTPoison.Response{body: body}}
  end

  def request_move(%{name: :error}, _world, _) do
    {:error, :forced_failure}
  end

  def request_move(%{name: :bad_content}, _world, _) do
    {:ok, %HTTPoison.Response{body: "hurr durr"}}
  end

  def request_move(%{name: :bad_move}, _world, _) do
    json = %{move: "NORTH"}
    body = Poison.encode!(json)
    {:ok, %HTTPoison.Response{body: body}}
  end

  setup_all do
    mocks = %{request_move: &request_move/3}
    {:ok, _pid} = BattleSnake.MockApi.start_link(mocks)
    :ok
  end

  describe "Move.next/1" do
    test "updates the location of snakes" do
      snake = build(:snake,
        name: :good_snake,
        url: "http://example.com",
        coords: [p(0, 0)])

      world = build(:world, snakes: [snake])

      assert %BattleSnake.World{} = Move.next(world)

      [snake] = Move.next(world).snakes

      assert snake.coords == [p(0, 1)]
    end
  end

  describe "Move.next/1 when a request worker dies" do
    test "chooses a default move" do
      for name <- ~w(bad_move bad_content error)a do
        snake = build(:snake, name: name, url: "http://example.com", coords: [p(0, 0)])
        world = build(:world, snakes: [snake])

        assert %BattleSnake.World{} = Move.next(world)

        [snake] = Move.next(world).snakes

        default_move = BattleSnake.Move.to_point(BattleSnake.Move.default_move)

        assert snake.coords == [default_move]
      end
    end
  end
end
