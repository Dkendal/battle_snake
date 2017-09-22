defmodule Bs.WinConditions do
  require BsWeb.GameForm

  @spec game_mode(binary) :: (Bs.World.t -> boolean)
  def game_mode(game_mode) do
    case game_mode do
      BsWeb.GameForm.singleplayer() ->
        &singleplayer/1
      BsWeb.GameForm.multiplayer() ->
        &multiplayer/1
    end
  end

  def singleplayer(world) do
    length(world.snakes) <= 0
  end

  def multiplayer(world) do
    length(world.snakes) <= 1
  end
end
