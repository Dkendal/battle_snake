defmodule BsWeb.TestController do
  use BsWeb, :controller

  def index(conn, params) do
    render(conn, "index.html")
  end
end

defmodule BsWeb.TestView do
  use BsWeb, :view
end
