defmodule BattleSnake.Api do
  alias Ecto.Changeset

  alias BattleSnake.{
    Api.Response,
    GameForm,
    HTTP,
    Move,
    Snake,
    SnakeForm,
    World}

  require Logger

  # @load_whitelist ~w(color head_url name taunt)a
  # @move_whitelist ~w(move taunt)a

  @callback load(%SnakeForm{}, %GameForm{}) :: Response.t
  @callback move(%Snake{}, %World{}) :: Response.t

  @doc """
  Load the Snake struct based on the configuration_form data for both the world
  and snake.

  POST /start
  """
  @spec load(%SnakeForm{}, %GameForm{}) :: Response.t
  def load(%{url: url}, data, request \\ &HTTP.post/4) do
    request_url = url <> "/start"
    api_response = response(request_url, request, data)
    update_in(api_response.parsed_response, fn
      {:ok, snake} ->
      (
        snake = put_in(snake["url"], url)
        {:ok, snake}
      )
      error ->
      (
        log_error(request_url, error, api_response)
        error
      )
    end)
    |> do_load
  end

  def do_load(response) do
    update_in response.parsed_response, fn
      {:ok, map} ->
      (
        {:ok, cast_load(map)}
      )
      response ->
        response
    end
  end

  def cast_load(map) do
    data = %Snake{}
    types = %{color: :string,
              head_url: :string,
              name: :string,
              taunt: :string, url: :string}
    {data, types}
    |> Changeset.cast(map, Map.keys(types))
    |> Changeset.validate_required([:name])
    |> Changeset.apply_changes
  end


  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(%{url: url, id: id}, world, request \\ &HTTP.post/4) do
    data = Poison.encode!(world, me: id)
    (url <> "/move")
    |> response(request, data)
    |> do_move
  end

  def do_move(response) do
    update_in response.parsed_response, fn
      {:ok, map} ->
      (
        {:ok, cast_move(map)}
      )
      response ->
        response
    end
  end

  def cast_move(map) do
    data = %Move{}
    types = %{move: :string, taunt: :string}
    {data, types}
    |> Changeset.cast(map, Map.keys(types))
    |> Changeset.validate_required([:move])
    |> Changeset.validate_inclusion(:move, ~w(up down left right))
    |> Changeset.apply_changes
  end

  defp response(url, request, data) do
    api_response = url
    |> request.(data, [], [])
    |> Response.new(as: %{})

    update_in(api_response.parsed_response, fn
      {:ok, map} ->
      (
        {:ok, map}
      )
      error ->
      (
        log_error(url, error, api_response)
        error
      )
    end)
  end

  defp log_error(url, error, api_response) do
    http_response = inspect(api_response.raw_response, color: false, pretty: true)
    ("""
    Could not process API response for #{url}:

    Poison JSON Parsing Error:
    #{inspect error}

    HTTPoison HTTP Response:
    #{http_response}
    """)
    |> Logger.debug
  end
end
