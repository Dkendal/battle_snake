defmodule BattleSnake.Movement do
  alias BattleSnake.World
  alias BattleSnake.Snake
  alias BattleSnake.Api
  alias BattleSnake.Move
  alias BattleSnake.Point
  alias BattleSnake.GameServer.State

  require Logger

  @sup_timeout :infinity

  @moduledoc """
  Updates the positions of all snakes on the board.
  """

  defmodule Worker do
    @api Application.get_env(:battle_snake, :snake_api)

    @spec run(BattleSnake.World.t, BattleSnake.Snake.t, timeout) :: BattleSnake.Point.t
    def run(%Snake{} = snake, %World{} = world, recv_timeout) do
      response = @api.request_move(snake, world, [recv_timeout: recv_timeout])
      response
      |> process_response
      |> Move.to_point
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

  @spec next(State.t) :: State.t
  def next(%State{} = state) do
    recv_timeout = state.game_form.recv_timeout

    %{state| world: next(state.world, recv_timeout)}
  end

  @doc """
  Fetch and update the position of all snakes
  """
  @spec next(World.t, timeout) :: World.t
  def next(world, recv_timeout \\ :infinity)
  def next(%World{} = world, recv_timeout) do
    options = [timeout: @sup_timeout]

    snakes = world.snakes

    snakes = Task.Supervisor.async_stream_nolink(
      BattleSnake.MoveSupervisor,
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

  defp move_snake({%Point{} = point, %Snake{} = snake}) do
    Snake.move(snake, point)
  end

  defp get_move_for_snake({{:ok, point}, snake}) do
    {point, snake}
  end

  defp get_move_for_snake({{:exit, e}, snake}) do
    Logger.debug """
    [#{snake.url}] failed to respond to /move
    #{inspect e, pretty: true}
    """

    move = Move.default_move()
    point = Move.to_point(move)
    {point, snake}
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
