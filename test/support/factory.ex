defmodule BattleSnake.MnesiaStrategy do
  use ExMachina.Strategy, function_name: :create

  def handle_create(record, _opts) do
    Mnesia.Repo.save(record)
  end
end

defmodule BattleSnake.Factory do
  use ExMachina
  use BattleSnake.MnesiaStrategy

  def world_factory do
    %BattleSnake.World{
    }
  end

  def state_factory do
    %BattleSnake.GameServer.State{
    }
  end
end
