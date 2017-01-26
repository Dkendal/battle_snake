defmodule BattleSnake.Api.GameControllerTest do
  alias BattleSnake.{
    GameForm,
    GameServer,
    SnakeForm,
  }

  use BattleSnake.ConnCase, async: false

  describe "GET index" do
    setup do
      # TODO repo should get cleaned up after each test.
      MnesiaTesting.teardown

      snake = %SnakeForm{url: "example.com"}

      %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.put_change(:id, 1)
      |> Ecto.Changeset.put_embed(:snakes, [snake])
      |> Ecto.Changeset.apply_changes
      |> Mnesia.Repo.save

      %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.put_change(:id, 2)
      |> Ecto.Changeset.put_embed(:snakes, [snake])
      |> Ecto.Changeset.apply_changes
      |> Mnesia.Repo.save

      GameServer.Registry.create 1

      on_exit fn ->
        BattleSnake.GameServerTesting.teardown
        MnesiaTesting.teardown
      end

      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert [%{"id" => 1,
                "snakes" => [%{"url" => "example.com"}],
                "status" => "suspend",
                "winners" => []},
              %{"id" => 2,
                "snakes" => [%{"url" => "example.com"}],
                "status" => "dead",
                "winners" => []}] =
        json_response(conn, 200)
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

      assert 1 == Enum.count GameForm.all

      assert [%GameForm{
                 delay: 1,
                 height: 2,
                 max_food: 3,
                 width: 4,
                 game_mode: "singleplayer",
                 snakes: [%SnakeForm{url: "example.com"}]}] =
        GameForm.all
    end
  end
end
