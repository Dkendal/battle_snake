defmodule BattleSnakeServer.GameChannelTest do
  use BattleSnakeServer.ChannelCase

  alias BattleSnakeServer.{Game, GameChannel}
  alias BattleSnakeServer.Snake, as: SnakeForm

  setup [:create_game, :join]

  describe "PUSH start" do
    test "start replies with status ok", %{socket: socket} do
      ref = push socket, "start"
      assert_reply ref, :ok
      assert_broadcast "tick", %{html: html}, 500
      assert html =~ "svg"
    end
  end

  describe "PUSH pause" do
    test "pauses the game", %{socket: socket} do
      ref = push socket, "start"
      assert_reply ref, :ok
      assert_broadcast "tick", _, 500
      ref = push socket, "pause"
      assert_reply ref, :ok
      refute_broadcast "tick", _, 500
    end
  end

  def join(context) do
    %{game: game} = context
    {:ok, _, socket} = socket("user_id", %{})
    |> subscribe_and_join(GameChannel, "game:#{game.id}")

    Map.put(context, :socket, socket)
  end

  def create_game(context) do
    snakes = [
      %SnakeForm{url: "localhost:3000"}
    ]

    game = %Game{snakes: snakes}
    |> Game.changeset
    |> Ecto.Changeset.apply_changes
    |> Game.save

    Map.put(context, :game, game)
  end
end
