defmodule BsWeb.GameControllerTest do
  use BsWeb.ConnCase

  alias BsRepo.GameForm

  setup do
    {:atomic, :ok} = :mnesia.clear_table(BsRepo.GameForm)
    {:atomic, :ok} = :mnesia.clear_table(:id_seq)
    :ok
  end

  describe "GET index" do
    test "lists all entries on index", %{conn: conn} do
      conn = get(conn, game_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing games"
    end
  end

  describe "POST create" do
    test "does the thing", %{conn: conn} do
      game_form = %{"width" => "100", "height" => "100"}

      conn = post(conn, game_path(conn, :create), game_form: game_form)

      [%{id: id}] = BsRepo.all(GameForm)

      assert redirected_to(conn, 302) == game_path(conn, :edit, id)

      [game] = BsRepo.all(GameForm)

      assert %GameForm{width: 100, height: 100} = game
    end
  end
end
