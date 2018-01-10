defmodule BsWeb.Channels.GameChannelTest do
  alias BsWeb.GameChannel

  use BsWeb.ChannelCase

  test "pushes the game state after joining" do
    id =
      insert(
        :game_form,
        snakes: [
          build(:snake_form),
          build(:snake_form)
        ]
      ).id

    sock = socket()

    {:ok, _, sock} = subscribe_and_join(sock, GameChannel, "game:#{id}")

    assert_broadcast("tick", %{
      content: %{
        board: %{
          id: _,
          gameId: _,
          food: _,
          turn: 0,
          snakes: snakes,
          deadSnakes: deadSnakes,
          width: _,
          height: _
        }
      }
    })

    assert 2 == length(snakes)
    assert 0 == length(deadSnakes)

    push(sock, "start")
  end
end
