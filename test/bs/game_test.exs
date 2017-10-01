defmodule Bs.GameServerTest do
  use Bs.Case, async: false

  setup do
    mock BsRepo

    expect BsRepo, :get!, fn BsWeb.GameForm, "1" ->
      build :game_form
    end

    on_exit &unload/0
  end

  test "#find starts new servers" do
    # assert {:ok, pid} =  Game.find("1")
  end

  test "#find returns running game servers" do
  end
end
