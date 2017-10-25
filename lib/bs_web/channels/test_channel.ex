defmodule BsWeb.TestChannel do
  alias Bs.Test

  use BsWeb, :channel

  def join("test", _params, socket) do
    {:ok, socket}
  end

  def handle_in("run:suite", %{"url" => url}, socket) do
    scenarios = Test.scenarios()

    assertions = Test.start(scenarios, url)

    spawn_link(fn ->
      Enum.map(assertions, fn
        :ok ->
          push(socket, "test:pass", %{})

        assertion ->
          view =
            Phoenix.View.render_one(
              assertion,
              BsWeb.AssertionErrorView,
              "show.json"
            )

          push(socket, "test:failed", view)
      end)
    end)

    {:reply, :ok, socket}
  end
end
