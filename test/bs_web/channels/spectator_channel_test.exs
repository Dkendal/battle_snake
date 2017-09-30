defmodule BsWeb.SpectatorChannelTest do
  alias Bs.Game.PubSub
  alias BsWeb.SpectatorChannel

  use BsWeb.ChannelCase

  describe "SpectatorChannel" do
    setup [:sub, :broadcast_state]

    test "renders content" do
      assert_broadcast "tick", %{content: _content}
    end
  end

  def broadcast_state(c) do
    state = build(:state)
    PubSub.broadcast(c.id, {:tick, state})
  end

  def sub _ do
    id = insert(:game_form).id
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(SpectatorChannel, "spectator:#{id}")

    [socket: socket, id: id]
  end
end
