defmodule BsWeb.Channels.GameChannelTest do
  alias BsWeb.GameChannel

  use BsWeb.ChannelCase

  test "can control stepping back and forth" do
    game_form =
      insert(:game_form, snakes: [build(:snake_form), build(:snake_form)])

    id = game_form.id

    sock = socket()

    {:ok, _, sock} = subscribe_and_join(sock, GameChannel, "game:#{id}")

    assert_broadcast("tick", msg)

    assert msg.content.status == :suspend
    assert msg.content.board.turn == 0
    assert 2 == length(msg.content.board.snakes)
    assert 0 == length(msg.content.board.deadSnakes)

    push(sock, "next")

    assert_broadcast("tick", msg)

    assert msg.content.status == :suspend
    assert msg.content.board.turn == 1

    push(sock, "prev")

    assert_broadcast("tick", msg)

    assert msg.content.status == :suspend
    assert msg.content.board.turn == 0
  end
end
