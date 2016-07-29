defmodule BattleSnakeServer.GameChannelTest do
  use BattleSnakeServer.ChannelCase

  alias BattleSnakeServer.{Game, GameChannel}

  setup [:create_game, :join]

  describe "PUSH start" do
    test "start replies with status ok", %{socket: socket} do
      ref = push socket, "start", %{"hello" => "there"}
      assert_reply ref, :ok, %{"hello" => "there"}
    end
  end

  describe "BROADCAST tick" do
    test "shout broadcasts to game:lobby", %{socket: socket} do
      push socket, "tick", %{"hello" => "all"}
      assert_broadcast "tick", %{"hello" => "all"}
    end

    test "broadcasts are pushed to the client", %{socket: socket} do
      broadcast_from! socket, "tick", %{"some" => "data"}
      assert_push "tick", %{"some" => "data"}
    end
  end

  def join(context) do
    {:ok, _, socket} = socket("user_id", %{some: :assign})
    |> subscribe_and_join(GameChannel, "game:#{context.id}")

    Map.put(context, :socket, socket)
  end

  def create_game(context) do
    game = %Game{}
    |> Game.changeset
    |> Ecto.Changeset.apply_changes
    |> Game.save

    Map.put(context, :id, game.id)
  end
end
