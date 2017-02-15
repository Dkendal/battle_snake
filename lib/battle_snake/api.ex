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
    data = Poison.encode!(data)

    api_response = request_url
    |> request.(data, [], [])
    |> Response.new(as: %{})

    api_response = put_in(api_response.url, url)

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
    |> do_log
  end


  def do_log(response) do
    with {:error, e} <- response.raw_response,
      do: Logger.debug("[#{response.url}] #{inspect(e)}")

    with {:error, e} <- response.parsed_response,
      do: Logger.debug("[#{response.url}] #{inspect(e)}")

    response
  end

  def do_load(response) do
    update_in response.parsed_response, fn
      {:ok, map} ->
        cast_load(map)
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

    changeset = {data, types}
    |> Changeset.cast(map, Map.keys(types))
    |> Changeset.validate_required([:name])

    if changeset.valid? do
      {:ok, Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end


  @doc """
  Get the move for a single snake.

  POST /move
  """
  @spec move(%Snake{}, %World{}) :: Response.t
  def move(%{url: url, id: id}, world, request \\ &HTTP.post/4) do
    data = Poison.encode!(world, me: id)
    url = (url <> "/move")

    api_response = url
    |> request.(data, [], [])
    |> Response.new(as: %{})

    api_response = put_in(api_response.url, url)

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

    api_response
    |> do_move
    |> do_log
  end

  def do_move(response) do
    update_in response.parsed_response, fn
      {:ok, map} ->
        cast_move(map)
      response ->
        response
    end
  end

  def cast_move(map) do
    data = %Move{}
    types = %{move: :string, taunt: :string}

    changeset = {data, types}
    |> Changeset.cast(map, Map.keys(types))
    |> Changeset.validate_required([:move])
    |> Changeset.validate_inclusion(:move, ~w(up down left right))

    if changeset.valid? do
      {:ok, Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
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
