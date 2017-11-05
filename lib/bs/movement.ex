alias Bs.GameState
alias Bs.Move
alias Bs.ChangesetError
alias Bs.Movement.Worker
alias Bs.Notification
alias Bs.Snake
alias Bs.World

defmodule Bs.Movement do
  require Logger

  @sup_timeout 10000
  @recv_timeout 5000

  @moduledoc """
  Updates the positions of all snakes on the board.
  """

  def next(%GameState{} = state) do
    %{state | world: next(state.world)}
  end

  @doc """
  Fetch and update the position of all snakes
  """
  def next(%World{} = world) do
    snakes =
      world
      |> workers()
      |> Stream.zip(world.snakes)
      |> Stream.map(&process/1)
      |> Enum.to_list()

    put_in(world.snakes, snakes)
  end

  def workers(world) do
    {:ok, sup} = Task.Supervisor.start_link()

    Task.Supervisor.async_stream_nolink(
      sup,
      world.snakes,
      Worker,
      :run,
      [world, [recv_timeout: @recv_timeout]],
      timeout: @sup_timeout
    )
  end

  def process({result, snake}) do
    move =
      case result do
        {:ok, move} ->
          move

        {:exit, e} ->
          """
          [#{snake.url}] failed to respond to /move
          #{inspect(e, pretty: true)}
          """
          |> Logger.debug()

          Move.default_move(snake)
      end

    Snake.move(snake, move)
  end
end

defmodule Bs.Movement.Worker do
  @http Application.get_env(:bs, :http)

  def run(%Snake{} = snake, %World{} = world, opts) do
    recv_timeout = Keyword.fetch!(opts, :recv_timeout)

    view =
      Phoenix.View.render(
        BsWeb.WorldView,
        "show.json",
        v: 2,
        world: world,
        snake: snake
      )

    data = Poison.encode!(view)

    {tc, response} =
      :timer.tc(@http, :post!, [
        "#{snake.url}/move",
        data,
        ["Content-Type": "application/json"],
        [recv_timeout: recv_timeout]
      ])

    params =
      response
      |> notify(id: world.game_id, snake_id: snake.id, tc: tc)
      |> Map.get(:body)
      |> Poison.decode!()

    changeset = Move.changeset(%Move{}, params)

    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      raise(ChangesetError, changeset)
    end
  end

  def notify(response, opts) do
    id = Keyword.fetch!(opts, :id)
    snake_id = Keyword.fetch!(opts, :snake_id)
    tc = Keyword.fetch!(opts, :tc)

    Notification.broadcast!(
      id,
      name: "move:response",
      rel: %{game_id: id, snake_id: snake_id},
      view: "response.json",
      data: [response: response, tc: tc]
    )

    response
  end
end
