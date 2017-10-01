defmodule Bs.World.FactoryTest do
  alias Bs.World.Factory
  alias Bs.World
  alias Bs.Snake

  use Bs.Case, async: false

  @url "http://example.com/start"
  @json "{\"width\":10,\"height\":10,\"game_id\":1}"

  @ok %HTTPoison.Response{
    status_code: 200,
    body: encode!(%{
      name: "example snake",
      taunt: "example taunt"
    })
  }

  setup do
    mock HTTPoison

    expect HTTPoison, :post, fn @url, @json, _, _ ->
      {:ok, @ok}
    end

    on_exit &unload/0
  end

  test "#build" do
    world = Factory.build build(
      :game_form,
      height: 10,
      width: 10,
      id: 1,
      snakes: [
        build(:snake_form)
      ])

    assert %World{
      game_form_id: 1,
      height: 10,
      width: 10,
      snakes: [
        %Snake{
          coords: [_, _, _],
          url: "http://example.com",
          taunt: "example taunt",
          name: "example snake"
        }
      ]
    } = world
  end
end
