defmodule Bs.MovementTest do
  alias Bs.Movement

  use Bs.Case, async: false
  use Bs.Point

  import Map
  import List

  @moduletag :capture_log

  test ".next updates snake locations" do
    actual =
      build(:world, snakes: [build(:snake, url: "down.mock")])
      |> Movement.next()

    assert [p(0, 1)] = actual.snakes |> first() |> get(:coords)
  end

  test ".next provides a default" do
    actual =
      build(:world, snakes: [build(:snake, url: "invalid.mock")])
      |> Movement.next()

    assert [p(0, -1)] = actual.snakes |> first() |> get(:coords)
  end
end
