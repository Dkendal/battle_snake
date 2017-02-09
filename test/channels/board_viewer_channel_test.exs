defmodule BattleSnake.BoardViewerChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.{
    BoardViewerChannel,
    GameServer
  }

  setup [:sub]

  @tag content_type: "html"
  test "relays broadcasts to clients" do
    broadcast_state()
    assert_broadcast "tick", %{content: _}
  end

  @tag content_type: "html"
  test "renders html" do
    broadcast_state()
    assert_broadcast "tick", %{content: content}
    content =~ ~r/<svg>/
  end

  @tag content_type: "json"
  test "renders json" do
    broadcast_state()
    assert_broadcast "tick", %{content: content}
    assert {:ok, _} = Poison.decode content
  end

  def sub c do
    content_type = c.content_type
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(BoardViewerChannel, "board_viewer:1", %{"contentType" => content_type})

    [socket: socket]
  end

  def broadcast_state() do
    state = build(:state)
    GameServer.PubSub.broadcast("1", %GameServer.State.Event{name: "test", data: state})
  end
end
