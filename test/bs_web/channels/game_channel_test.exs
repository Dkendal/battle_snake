defmodule BsWeb.Channels.GameChannelTest do
  alias BsWeb.GameChannel
  use BsWeb.ChannelCase

  test "can control stepping back and forth" do
    Bs.ApiMock
    |> expect(:start, fn "snake1", _, _ ->
      %Response{status_code: 200, body: encode!(%{name: "snake1"})}
    end)
    |> expect(:start, fn "snake2", _, _ ->
      raise Error
    end)
    |> expect(:move, fn "snake1", _, _ ->
      %Response{status_code: 200, body: encode!(%{move: "up"})}
    end)

    game_form =
      insert(
        :game_form,
        snakes: [
          build(:snake_form, url: "snake1"),
          build(:snake_form, url: "snake2")
        ]
      )

    id = game_form.id

    sock = socket()

    {:ok, _, sock} = subscribe_and_join(sock, GameChannel, "game:#{id}")

    assert_broadcast("tick", msg)

    assert msg.content.status == :suspend
    assert msg.content.board.turn == 0
    assert 2 == length(msg.content.board.snakes)
    [snake1, snake2] = msg.content.board.snakes
    assert snake1.id |> String.length() == 36
    assert snake2.id |> String.length() == 36

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
