defmodule Bs.Movement do
  alias Bs.World
  alias Bs.Snake
  alias Bs.Api
  alias Bs.Move
  alias Bs.GameState

  require Logger

  @sup_timeout 10_000

  @moduledoc """
  Updates the positions of all snakes on the board.
  """

  defmodule Worker do
    @api Application.get_env(:bs, :snake_api)

    def run(%Snake{} = snake, %World{} = world, recv_timeout) do
      response = @api.request_move(snake, world, [recv_timeout: recv_timeout])

      process_response(response)
    end

    def process_response(val, acc \\ [])

    def process_response({:error, e}, acc) do
      Process.exit(self(), {:shutdown, {e, acc}})
    end

    def process_response({:ok, %Move{} = move}, _acc) do
      move
    end

    def process_response({:ok, %HTTPoison.Response{} = response}, acc) do
      Poison.decode(response.body)
      |> process_response([response|acc])
    end

    def process_response({:ok, json}, acc) when is_map(json) do
      Api.cast_move(json)
      |> process_response([json|acc])
    end
  end

  def next(%GameState{} = state) do
    recv_timeout = state.game_form.recv_timeout

    %{state| world: next(state.world, recv_timeout)}
  end

  @doc """
  Fetch and update the position of all snakes
  """
  def next(world, recv_timeout \\ 10_000)
  def next(%World{} = world, recv_timeout) do
    options = [timeout: @sup_timeout]

    snakes = world.snakes

    snakes = Task.Supervisor.async_stream_nolink(
      Bs.MoveSupervisor,
      snakes,
      Worker,
      :run,
      [world, recv_timeout],
      options)
      |> Stream.zip(snakes)
      |> Stream.map(&get_move_for_snake/1)
      |> Stream.map(&move_snake/1)
      |> Enum.to_list

    put_in(world.snakes, snakes)
  end

  defp move_snake({%Move{} = move, %Snake{} = snake}) do
    Snake.move(snake, move)
  end

  defp get_move_for_snake({{:ok, point}, snake}) do
    {point, snake}
  end

  defp get_move_for_snake({{:exit, e}, snake}) do
    Logger.debug """
    [#{snake.url}] failed to respond to /move
    #{inspect e, pretty: true}
    """

    move = Move.default_move(snake)

    {move, snake}
  end
end

defmodule Bs.MoveSupervisor do
  use Supervisor

  def init(:ok) do
    import Supervisor.Spec

    children = [
      worker(Task, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
