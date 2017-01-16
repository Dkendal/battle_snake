defmodule BattleSnake.MockApi do
  @behaviour BattleSnake.Api

  @move %BattleSnake.Move{
    taunt: "test",
    move: "up",
  }

  def load(_form, _game) do
    {:ok, %BattleSnake.Snake{}}
  end

  def start, do: {:ok, [:fake]}

  def move(_, _), do: {:ok, @move}
end
