defmodule Bs.MockApi do
  alias Bs.Snake
  alias Bs.World

  use GenServer

  @behaviour Bs.Api

  @move {:ok, %HTTPoison.Response{body: Poison.encode!(%{move: "up"})}}

  def start(state) do
    GenServer.start(__MODULE__, state, name: __MODULE__)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def move(x, y) do
    Bs.Api.move(x, y, mock_post(@move))
  end

  def request_move(target, data, ops \\ [])

  def request_move(%Snake{} = snake, %World{} = world, opts) do
    GenServer.call(__MODULE__, {:request_move, [snake, world, opts]})
  end

  def handle_call({:request_move, args}, _from, mocks) do
    result = :erlang.apply(mocks[:request_move], args)
    {:reply, result, mocks}
  end

  def mock_post(return) do
    fn
      url, body, headers, options
      when is_binary(url) and is_binary(body) and is_list(headers) and
             is_list(options) ->
        return

      url, body, headers, options ->
        raise """
        Expected mock_post(url:binary, body:binary, headers:keyword, options:keyword)

        received:
        url: #{inspect(url, limit: 0)}
        body: #{inspect(body, limit: 0)}
        headers: #{inspect(headers, limit: 0)}
        options: #{inspect(options, limit: 0)}
        """
    end
  end
end
