defmodule BsWeb.TestChannelTest do
  alias BsWeb.TestChannel

  use BsWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(TestChannel, "test", %{})

    [socket: socket]
  end

  test "push run:suite", %{socket: socket} do
    ref = push(socket, "run:suite", %{"url" => "up.mock"})

    assert_reply(ref, :ok)
  end
end
