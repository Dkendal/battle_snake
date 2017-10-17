defmodule BsWeb.TestChannelTest do
  alias BsWeb.TestChannel

  use BsWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(TestChannel, "test", %{})

    [socket: socket]
  end

  test "running the test suite", %{socket: socket} do
    ref = push(socket, "run:suite", %{})

    assert_reply(ref, :ok)
  end
end
