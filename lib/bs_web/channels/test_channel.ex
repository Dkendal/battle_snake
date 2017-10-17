defmodule BsWeb.TestChannel do
  use BsWeb, :channel

  def join("test", _params, socket) do
    {:ok, socket}
  end

  def handle_in("run:suite", _params, socket) do
    {:reply, :ok, socket}
  end
end
