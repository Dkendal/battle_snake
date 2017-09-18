defmodule BattleSnakeWeb.SpectatorChannelTest do
  use BattleSnakeWeb.ChannelCase

  alias BattleSnake.GameServer
  alias BattleSnake.GameStateEvent
  alias BattleSnakeWeb.SpectatorChannel

  describe "SpectatorChannel" do
    setup [:sub, :broadcast_state]

    test "renders content" do
      assert_broadcast "tick", %{content: _content}
    end
  end

  def broadcast_state(c) do
    state = build(:state)
    GameServer.PubSub.broadcast(c.id, %GameStateEvent{name: "test", data: state})
  end

  def sub _ do
    id = create(:game_form).id
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(SpectatorChannel, "spectator:#{id}")

    [socket: socket, id: id]
  end
end
