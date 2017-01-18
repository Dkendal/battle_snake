defmodule BattleSnake.MockApi do
  alias BattleSnake.Api.Response

  @behaviour BattleSnake.Api

  def load(_form, _game) do
    %Response{
      raw_response: {
        :ok,
        %HTTPoison.Response{body: "mocked response"}},
      parsed_response: {
        :ok,
        %BattleSnake.Snake{}}}
  end

  def start, do: {:ok, [:fake]}

  def move(_, _) do
    %Response{
      raw_response: {
        :ok,
        %HTTPoison.Response{body: "mocked response"}},
      parsed_response: {
        :ok,
        %BattleSnake.Move{move: "up"}}}
  end
end
