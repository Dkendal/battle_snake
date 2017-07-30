defmodule BattleSnakeWeb.Api.GameFormControllerTest do
  alias BattleSnake.{
    GameForm,
    GameServer,
    SnakeForm,
  }

  use BattleSnakeWeb.ConnCase, async: false

  setup do
    MnesiaTesting.teardown
    on_exit fn ->
      BattleSnake.GameServerTesting.teardown
      MnesiaTesting.teardown
    end
    :ok
  end

  describe "GET index" do
    @snake %SnakeForm{url: "example.com"}

    setup do
      %GameForm{}
      |> GameForm.changeset(%{})
      |> Ecto.Changeset.put_change(:id, 1)
      |> Ecto.Changeset.put_embed(:snakes, [@snake])
      |> Ecto.Changeset.apply_changes
      |> Mnesia.Repo.save
      :ok
    end

    test "lists all games", %{conn: conn} do
      conn = get conn, api_game_path(conn, :index)
      assert [] =
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
