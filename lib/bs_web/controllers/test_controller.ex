defmodule BsWeb.TestController do
  use BsWeb, :controller

  def index(conn, params) do
    render(conn, "index.html")
  end
end
