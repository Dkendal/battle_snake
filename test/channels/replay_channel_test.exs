defmodule BattleSnake.ReplayChannelTest do
  alias BattleSnake.ReplayChannel
  alias BattleSnake.Replay.PlayBack.Frame
  use BattleSnake.ChannelCase

  alias BattleSnake.ReplayChannel

  describe "ReplayChannel.handle_info(:after_join, socket)" do
    test "subscribes the caller to the topic" do
      topic = "replay:game-1"
      socket = socket("user-1", %{game_id: "game-1"})

      ReplayChannel.handle_info(:after_join, socket)
      BattleSnake.GameServer.PubSub.broadcast(topic, :hello)
      assert_receive :hello
    end
  end

  describe "ReplayChannel.handle_info(frame, socket) when content type is HTML" do
    setup do
      {:ok, _, socket} = socket("user-1", %{})
      |> subscribe_and_join(ReplayChannel, "replay:html:game-1")

      state = build(:state)
      frame = %Frame{data: state}

      ReplayChannel.handle_info(frame, socket)

      [socket: socket]
    end

    test "broadcasts the received frame" do
      assert_broadcast "tick", %{content: "<div" <> _}
    end
  end
end
