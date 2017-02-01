defmodule BattleSnake.Api do
  alias BattleSnake.{
    Api.Response,
    GameForm,
    HTTP,
    Move,
    Snake,
    SnakeForm,
    World}

  @callback load(%SnakeForm{}, %GameForm{}) :: Response.t
  @callback move(%Snake{}, %World{}) :: Response.t

  @doc """
  Load the Snake struct based on the configuration_form data for both the world
  and snake.

  POST /start
  """
  @spec load(%SnakeForm{}, %GameForm{}) :: Response.t
  def load(snake_form, game_form, request \\ &HTTP.post/4) do
    response(snake_form, "/start", request,
      data: game_form,
      as: %Snake{
        url: snake_form.url})
  end

  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(snake, world, request \\ &HTTP.post/4) do
    response(snake, "/move", request,
      data: Poison.encode!(world, me: snake),
      as: %Move{})
  end

  defp response(%{url: url}, path, request, opts) do
    data = Keyword.fetch!(opts, :data)
    struct = Keyword.fetch!(opts, :as)
    (url <> path)
    |> request.(data, headers(), options())
    |> Response.new(as: struct)
  end

  defp options do
    []
  end

  defp headers() do
    []
  end
end
