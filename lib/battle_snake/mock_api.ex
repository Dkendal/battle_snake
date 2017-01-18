defmodule BattleSnake.MockApi do
  alias BattleSnake.Api.Response

  @behaviour BattleSnake.Api

  @move %BattleSnake.Move{
    taunt: "test",
    move: "up",
  }

  def load(_form, _game) do
    %Response{
      raw_response: {
        :ok,
        %HTTPoison.Response{body: "mocked response"}},
      parsed_response: {
        :ok,
        %BattleSnake.Snake{}}
    }
  end

  def start, do: {:ok, [:fake]}

  def move(_, _), do: {:ok, @move}
end
