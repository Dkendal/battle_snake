defmodule BattleSnakeWeb.ReplayChannelTest do
  alias BattleSnakeWeb.ReplayChannel
  alias BattleSnake.Replay.PlayBack.Frame
  use BattleSnakeWeb.ChannelCase

  alias BattleSnakeWeb.ReplayChannel

  describe "ReplayChannel.handle_info(:after_join, socket)" do
    test "subscribes the caller to the topic" do
      topic = "replay:game-1"
      socket = socket("user-1", %{game_id: "game-1"})

      ReplayChannel.handle_info(:after_join, socket)
      BattleSnake.GameServer.PubSub.broadcast(topic, :hello)
      assert_receive :hello
    end
  end
end
