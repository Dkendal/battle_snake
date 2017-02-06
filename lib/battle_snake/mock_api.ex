defmodule BattleSnake.MockApi do
  @behaviour BattleSnake.Api

  def start, do: {:ok, [:fake]}

  def load(x, y) do
    BattleSnake.Api.load(x, y, fn _, _, _, _ ->
      {:ok,
       %HTTPoison.Response{
         body: Poison.encode!(%{name: "mock-snake"})}}
    end)
  end

  def move(x, y) do
    BattleSnake.Api.move(x, y, fn _, _, _, _ ->
      {:ok,
       %HTTPoison.Response{
         body: Poison.encode!(%{move: "up"})}}
    end)
  end
end
