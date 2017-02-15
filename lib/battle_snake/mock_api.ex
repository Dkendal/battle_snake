defmodule BattleSnake.MockApi do
  @behaviour BattleSnake.Api

  def start, do: {:ok, [:fake]}

  @snake {:ok, %HTTPoison.Response{body: Poison.encode!(%{name: "mock-snake"})}}
  @move {:ok, %HTTPoison.Response{body: Poison.encode!(%{move: "up"})}}

  def load(x, y) do
    BattleSnake.Api.load(x, y, mock_post(@snake))
  end

  def move(x, y) do
    BattleSnake.Api.move(x, y, mock_post(@move))
  end

  def mock_post(return) do
    fn
      (url, body, headers, options)
      when is_binary(url)
      and is_binary(body)
      and is_list(headers)
      and is_list(options) -> return

      (url, body, headers, options) ->
        raise """
        Expected mock_post(url:binary, body:binary, headers:keyword, options:keyword)

        received:
        url: #{inspect url, limit: 0}
        body: #{inspect body, limit: 0}
        headers: #{inspect headers, limit: 0}
        options: #{inspect options, limit: 0}
        """
    end
  end
end
