defmodule BsWeb.Router do
  use BsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BsWeb do
    # Use the default browser stack
    pipe_through(:browser)

    resources("/test", TestController)
    resources("/", GameController)
  end

  scope "/", BsWeb do
    pipe_through(:api)

    post("/example/start", ExampleController, :start)
    post("/example/move", ExampleController, :move)
  end
end
