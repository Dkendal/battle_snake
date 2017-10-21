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
    :meck.new(HTTPoison)

    :meck.expect(HTTPoison, :post!, fn _, _, _, _ ->
      %HTTPoison.Response{body: ~s/{"move":"up"}/}
    end)

    ref = push(socket, "run:suite", %{"url" => "http://localhost:4000"})

    assert_reply(ref, :ok)
  end
end
