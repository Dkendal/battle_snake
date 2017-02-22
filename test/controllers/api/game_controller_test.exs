defmodule BattleSnake.Api.GameControllerTest do
  alias BattleSnake.{
    GameForm,
    GameServer,
    SnakeForm,
  }

  use BattleSnake.ConnCase, async: false

  describe "GET index" do
    setup do
      snakes = build_list(2, :snake, url: sequence("example.com:"), coords: [])
      game_form = create(:game_form, snakes: snakes)
      GameServer.Registry.create(game_form, game_form.id)
      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert(
        [%{"id" => _,
           "status" => "suspend",
           "winners" => [],
           "snakes" => [
             %{"coords" => [],
               "health_points" => 100,
               "id" => _,
               "name" => "",
               "taunt" => ""},
             %{"coords" => [],
               "health_points" => 100,
               "id" => _,
               "name" => "",
               "taunt" => ""}]}] = json_response(conn, 200))
    end
  end

  describe "POST create" do
    test "creates a new GameForm", %{conn: conn} do
      params = %{"game_form" => %{"delay" => "1",
                                  "height" => "2",
                                  "max_food" => "3",
                                  "width" => "4",
                                  "game_mode" => "singleplayer",
                                  "snakes" => [%{url: "example.com"}]}}

      post conn, api_game_path(conn, :create), params

      assert 1 == Enum.count Mnesia.Repo.all(GameForm)

      assert [%GameForm{
                 delay: 1,
                 height: 2,
                 max_food: 3,
                 width: 4,
                 game_mode: "singleplayer",
                 snakes: [%SnakeForm{url: "example.com"}]}] =
        Mnesia.Repo.all(GameForm)
    end
  end
end
