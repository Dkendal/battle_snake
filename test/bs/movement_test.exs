defmodule Bs.MovementTest do
  alias Bs.Movement

  use Bs.Case, async: false
  use Bs.Point

  import Map
  import List

  test ".next updates snake locations" do
    Bs.ApiMock
    |> expect(:move, fn "my.snake", json, _ ->
      assert {:ok, _} = Poison.decode(json)
      %Response{body: encode!(%{move: "down"})}
    end)

    actual =
      build(:world, snakes: [build(:snake, url: "my.snake")])
      |> Movement.next()

    assert [p(0, 1)] = actual.snakes |> first() |> get(:coords)
  end

  test ".next provides a default" do
    actual =
      build(:world, snakes: [build(:snake, url: "my.snake")])
      |> Movement.next()

    assert [p(0, -1)] = actual.snakes |> first() |> get(:coords)
  end
end
