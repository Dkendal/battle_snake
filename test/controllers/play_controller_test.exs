defmodule BsWeb.PlayControllerTest do
  alias BsWeb.GameForm
  use BsWeb.ConnCase

  describe "GET show" do
    test "it is OK", %{conn: conn} do
      {:ok, game} = BsRepo.insert %GameForm{}

      conn = get conn, play_path(conn, :show, game.id)

      assert html_response(conn, 200)
    end
  end
end
