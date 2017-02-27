defmodule BattleSnake.BoardViewerChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.{
    BoardViewerChannel,
    GameServer
  }

  setup [:sub, :broadcast_state]

  @tag content_type: "html"
  test "relays broadcasts to clients" do
    assert_broadcast "tick", %{content: _}
  end

  @tag content_type: "html"
  test "renders html" do
    assert_broadcast "tick", %{content: content}
    content =~ ~r/<svg>/
  end

  @tag content_type: "json"
  test "renders json" do
    assert_broadcast "tick", %{content: content}
    assert {:ok, board} = Poison.decode content
    assert is_list(board["food"]), "food is not in board: #{inspect board}"
    assert is_list(board["snakes"])
  end

  def broadcast_state(c) do
    state = build(:state)
    GameServer.PubSub.broadcast(c.id, %GameServer.State.Event{name: "test", data: state})
  end

  def sub c do
    id = create(:game_form).id
    content_type = c.content_type
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(BoardViewerChannel, "board_viewer:#{id}", %{"contentType" => content_type})

    [socket: socket, id: id]
  end
end
