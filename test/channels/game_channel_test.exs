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

  describe "PUSH prev" do
    test "responds with ok", %{socket: socket} do
      push socket, "start"
      ref = push socket, "prev"
      assert_reply ref, :ok
    end

    test "does nothing if the game there is no running game", %{socket: socket} do
      ref = push socket, "prev"
      assert_reply ref, :ok
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

    test "does nothing if the game there is no running game", %{socket: socket} do
      ref = push socket, "pause"
      assert_reply ref, :ok
    end
  end

  describe "PUSH stop" do
    test "stops a running game", %{socket: socket} do
      ref = push socket, "start"
      assert_reply ref, :ok
      assert_broadcast "tick", _, 500
      ref = push socket, "stop"
      assert_reply ref, :ok
      refute_broadcast "tick", _, 500
    end

    test "does nothing if there is no game running", %{socket: socket} do
      ref = push socket, "stop"
      assert_reply ref, :ok
    end
  end

  describe "PUSH next" do
    test "steps through a single move", %{socket: socket} do
      push socket, "start"
      push socket, "pause"
      flush()
      push socket, "next"
      assert_broadcast "tick", _
    end

    test "starts a new game if none are running", %{socket: socket} do
      push socket, "next"
      assert_broadcast "tick", _
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

    game = %Game{snakes: snakes, delay: 0}
    |> Game.changeset
    |> Ecto.Changeset.apply_changes
    |> Game.save

    Map.put(context, :game, game)
  end

  def flush() do
    # flush all messages
    receive do
      _ -> :ok
    after 10 -> :ok
    end
  end
end
