alias Bs.GameState
alias Bs.Move
alias Bs.Movement.Worker
alias Bs.Snake
alias Bs.World

defmodule Bs.Movement do
  require Logger

  @sup_timeout 10000

  @moduledoc """
  Updates the positions of all snakes on the board.
  """

  def next(%GameState{} = state) do
    recv_timeout = state.game_form.recv_timeout

    %{state | world: next(state.world, recv_timeout)}
  end

  @doc """
  Fetch and update the position of all snakes
  """
  def next(world, recv_timeout \\ 10000)

  def next(%World{} = world, recv_timeout) do
    options = [timeout: @sup_timeout]

    snakes = world.snakes

    {:ok, sup} = Task.Supervisor.start_link()

    args = [world, recv_timeout]

    snakes =
      sup
      |> Task.Supervisor.async_stream_nolink(
           snakes,
           Worker,
           :run,
           args,
           options
         )
      |> Stream.zip(snakes)
      |> Stream.map(&get_move_for_snake/1)
      |> Stream.map(&move_snake/1)
      |> Enum.to_list()

    put_in(world.snakes, snakes)
  end

  defp move_snake({%Move{} = move, %Snake{} = snake}) do
    Snake.move(snake, move)
  end

  defp get_move_for_snake({{:ok, point}, snake}) do
    {point, snake}
  end

  defp get_move_for_snake({{:exit, e}, snake}) do
    Logger.debug("""
    [#{snake.url}] failed to respond to /move
    #{inspect(e, pretty: true)}
    """)

    move = Move.default_move(snake)

    {move, snake}
  end
end

defmodule Bs.Movement.Worker do
  def run(%Snake{} = snake, %World{} = world, recv_timeout) do
    data = Poison.encode!(world, me: snake.id)

    headers = ["Content-Type": "application/json"]

    params =
      "#{snake.url}/move"
      |> HTTPoison.post!(data, headers, recv_timeout: recv_timeout)
      |> Map.get(:body)
      |> Poison.decode!()

    changeset = Move.changeset(%Move{}, params)

    if changeset.valid? do
      Ecto.Changeset.apply_changes(changeset)
    else
      changeset.errors
      |> inspect
      |> raise
    end
  end
end
