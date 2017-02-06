defmodule BattleSnake.GameAdminChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.GameAdminChannel
  alias BattleSnake.GameServer

  setup do
    game_id = "1"

    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(GameAdminChannel, "game_admin:" <> game_id)

    {:ok, socket: socket}
  end

  describe "push $command" do
    setup c do
      GameServer.PubSub.subscribe("1")
      ref = push(c.socket, "resume")
      [ref: ref]
    end

    test "responds with ok", c do
      assert_reply c.ref, :ok
    end

    test "sends message to the pub sub", c do
      assert_receive %GameServer.Command{name: "resume", data: %{}}
    end
  end
end
