defmodule BsWeb.Test.ExampleController do
  use BsWeb, :controller

  def start(conn, _params) do
    (:rand.uniform() * 1000)
    |> round
    |> Process.sleep()

    render(conn, "start.json")
  end

  def move(conn, params) do
    render(conn, "move.json", params)
  end
end
