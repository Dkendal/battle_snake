defmodule BattleSnake.World.Move do
  alias BattleSnake.World
  alias BattleSnake.Snake
  alias BattleSnake.Api
  alias BattleSnake.Move

  require Logger

  @moduledoc """
  Updates the positions of all snakes on the board.
  """

  defmodule Worker do
    @api Application.get_env(:battle_snake, :snake_api)

    @spec run(BattleSnake.World.t, BattleSnake.Snake.t) :: BattleSnake.Snake.t
    def run(%Snake{} = snake, %World{} = world) do
      response = @api.request_move(snake, world)

      point = response
      |> process_response
      |> Move.to_point

      Snake.move(snake, point)
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

  @doc """
  Fetch and update the position of all snakes
  """
  @spec next(World.t) :: World.t
  def next(world) do
    snakes = world.snakes

    snakes = Task.Supervisor.async_stream_nolink(
      BattleSnake.MoveSupervisor,
      snakes,
      Worker,
      :run,
      [world])
      |> Stream.zip(snakes)
      |> Stream.map(&collect_results/1)
      |> Enum.to_list

    put_in(world.snakes, snakes)
  end

  defp collect_results({{:ok, %{id: id} = snake}, %{id: id}}) do
    snake
  end

  defp collect_results({{:exit, e}, snake}) do
    Logger.debug """
    [#{snake.url}] failed to respond to /move
    #{inspect e, pretty: true}
    """

    move = Move.default_move()
    point = Move.to_point(move)
    Snake.move(snake, point)
  end
end

defmodule BattleSnake.MoveSupervisor do
  use Supervisor

  def init(:ok) do
    import Supervisor.Spec

    children = [
      worker(Task, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
