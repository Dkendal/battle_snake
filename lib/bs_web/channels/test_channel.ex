defmodule BsWeb.TestChannel do
  alias Bs.Test

  use BsWeb, :channel

  def join("test", _params, socket) do
    {:ok, socket}
  end

  def handle_in("run:suite", %{"url" => url}, socket) do
    scenarios = Test.scenarios()

    assertions = Test.suite(scenarios, url)

    payload = %{
      scenarios: scenarios,
      assertions: assertions
    }

    {:reply, {:ok, payload}, socket}
  end
end
