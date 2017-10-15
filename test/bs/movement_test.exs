defmodule Bs.MovementTest do
  alias Bs.Movement

  use Bs.Case, async: false
  use Bs.Point

  import Map
  import List

  @moduletag :capture_log

  test ".next updates snake locations" do
    mock(HTTPoison)

    expect(HTTPoison, :post!, fn "http://example.com/move", _, _, _ ->
      %HTTPoison.Response{body: ~s({"move":"down"})}
    end)

    actual =
      build(:world, snakes: [build(:snake, url: "http://example.com")])
      |> Movement.next()

    assert [p(0, 1)] = actual.snakes |> first() |> get(:coords)

    validate(HTTPoison)
    unload(HTTPoison)
  end

  test ".next provides a default" do
    mock(HTTPoison)

    expect(HTTPoison, :post!, fn "http://example.com/move", _, _, _ ->
      %HTTPoison.Response{body: ~s({"move":"sup"})}
    end)

    actual =
      build(:world, snakes: [build(:snake, url: "http://example.com")])
      |> Movement.next()

    assert [p(0, -1)] = actual.snakes |> first() |> get(:coords)

    validate(HTTPoison)
    unload(HTTPoison)
  end
end
