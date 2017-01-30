defmodule BattleSnake.Factory do
  use ExMachina

  def world_factory do
    %BattleSnake.World{
    }
  end

  def state_factory do
    %BattleSnake.GameServer.State{
    }
  end
end
