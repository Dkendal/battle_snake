defmodule BsWeb.TestController do
  use BsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
