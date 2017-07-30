defmodule BattleSnakeWeb.Api.GameControllerTest do
  alias BattleSnakeWeb.GameForm
  alias BattleSnakeWeb.SnakeForm

  use BattleSnakeWeb.ConnCase, async: false

  describe "GET index" do
    test "lists all games", %{conn: conn} do
      use BattleSnake.Point

      game_form = build(:game_form,
        id: "game-1",
        snakes: [
          build(:snake, id: "snake-1", name: "SnakeOne", coords: [p(0, 0)]),
          build(:snake, id: "snake-2", name: "SnakeTwo", coords: [p(1, 1)]),
        ]
      )

      import BattleSnake.GameResultSnake

      {:ok, d, _} = DateTime.from_iso8601("2017-01-01T12:00:00.000000Z")

      {:atomic, :ok} =
        Mnesia.transaction(fn ->
          game_form |> Mnesia.struct2record |> Mnesia.write

          game_result_snake(
            id: "game-result-snake-1",
            created_at: d,
            game_id: "game-1",
            snake_id: "snake-1",
            snake_name: "SnakeOne",
            snake_url: "snake.one.com"
          )
          |> Mnesia.write
        end)

      conn = get conn, api_game_path(conn, :index)

      expected = [
        %{
          "id" => "game-1",
          "status" => "dead",
          "winners" => [
            %{
              "created_at" => "2017-01-01T12:00:00.000000Z",
              "game_id" => "game-1",
              "snake_name" => "SnakeOne",
              "snake_url" => "snake.one.com"
            }
          ],
          "snakes" => [
            %{
              "coords" => [[0, 0]],
              "health_points" => 100,
              "id" => "snake-1",
              "name" => "SnakeOne",
              "taunt" => ""
            },
            %{
              "coords" => [[1, 1]],
              "health_points" => 100,
              "id" => "snake-2",
              "name" => "SnakeTwo",
              "taunt" => ""
            }
          ]
        }
      ]

      assert(expected == json_response(conn, 200))
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
