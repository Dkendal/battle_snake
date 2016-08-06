defmodule BattleSnakeServer.Snake.MockApi do
  @behaviour BattleSnakeServer.Snake.Api

  @move %BattleSnake.Move{
    taunt: "test",
    move: "up",
  }

  def load(_form, _game) do
    %BattleSnake.Snake{}
  end

  def start, do: {:ok, [:fake]}

  def move(_, _), do: @move
end
