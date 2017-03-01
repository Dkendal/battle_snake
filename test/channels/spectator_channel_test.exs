defmodule BattleSnake.SpectatorChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.{
    SpectatorChannel,
    GameServer
  }

  describe "SpectatorChannel" do
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
  end

  test "channels only get the content type they subscribed to" do
    game_form = create(:game_form)
    id = game_form.id
    channel = SpectatorChannel

    caller = self()

    spawn_link fn ->
      topic = "spectator:json:#{id}"
      assigns = %{"contentType" => "json"}
      {:ok, _, socket} =
        "user-1"
        |> socket(%{})
        |> subscribe_and_join(channel, topic, assigns)

      forward_msg = fn f ->
        receive do
          x -> send(caller, {:json, x}) && f.(f)
        end
      end

      forward_msg.(forward_msg)
    end

    spawn_link fn ->
      topic = "spectator:html:#{id}"
      assigns = %{"contentType" => "html"}
      {:ok, _, socket} =
        "user-1"
        |> socket(%{})
        |> subscribe_and_join(channel, topic, assigns)

      forward_msg = fn f ->
        receive do
          x -> send(caller, {:html, x}) && f.(f)
        end
      end

      forward_msg.(forward_msg)
    end

    broadcast_state(%{id: id})

    assert_receive {:html, %Phoenix.Socket.Broadcast{event: "tick", payload: %{content: "<div" <> _ }}}
    refute_receive {:html, %Phoenix.Socket.Broadcast{event: "tick", payload: %{content: "{" <> _ }}}
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
      |> subscribe_and_join(SpectatorChannel, "spectator:#{content_type}:#{id}", %{"contentType" => content_type})

    [socket: socket, id: id]
  end
end
