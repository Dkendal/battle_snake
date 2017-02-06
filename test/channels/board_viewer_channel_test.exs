defmodule BattleSnake.BoardViewerChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.{
    BoardViewerChannel,
    GameServer
  }

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(BoardViewerChannel, "board_viewer:1")

    {:ok, socket: socket}
  end

  test "relays broadcasts to clients" do
    state = build(:state)
    GameServer.PubSub.broadcast("1", %GameServer.State.Event{name: "test", data: state})
    assert_broadcast "tick", %{html: _}
  end
end
