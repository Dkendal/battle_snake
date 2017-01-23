defmodule BattleSnake.Router do
  use BattleSnake.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BattleSnake do
    pipe_through :browser # Use the default browser stack

    resources "/", GameController

    resources "/play", PlayController, only: [:show]
  end

  scope "/api", BattleSnake.Api, as: :api do
    pipe_through :api

    resources "/games", GameController
  end
end
