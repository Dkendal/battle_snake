defmodule BattleSnakeWeb.Router do
  use BattleSnakeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BattleSnakeWeb do
    pipe_through :browser # Use the default browser stack

    resources "/", GameController

    resources "/play", PlayController, only: [:show]
    resources "/skin", SkinController, only: [:show]
  end

  scope "/test", BattleSnakeWeb.Test, as: :test do
    pipe_through :api

    get "/example/start", ExampleController, :start
    get "/example/move", ExampleController, :move
    post "/example/start", ExampleController, :start
    post "/example/move", ExampleController, :move

    resources "/snake", SnakeTestController, only: [:index]
  end

  scope "/api", BattleSnakeWeb.Api, as: :api do
    pipe_through :api

    resources "/games", GameController
    resources "/game_forms", GameFormController
    resources "/game_servers", GameServerController
  end
end
