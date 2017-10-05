defmodule BsWeb.GameAdminChannelTest do
  alias BsWeb.GameAdminChannel

  use BsWeb.ChannelCase

  setup do
    {:ok, _, socket} = subscribe_and_join(
      socket(),
      GameAdminChannel,
      "admin",
      %{"id" => "1"}
    )

    [socket: socket]
  end

  test "pushing an unknown action", %{socket: socket} do
    ref = push socket, "sup", %{}
    assert_reply ref, :error
  end

  @tag :skip
  test "pushing cont", %{socket: socket} do
    ref = push socket, "cont", %{}
    assert_reply ref, :ok
  end
end
